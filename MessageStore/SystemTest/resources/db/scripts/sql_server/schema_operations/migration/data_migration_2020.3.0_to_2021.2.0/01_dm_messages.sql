SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [CONNECT_MS].[dataMigrationFrom2020300To2021200_Messages]
(
	@p_retentionDays    INT,
	@p_batchSize    INT
)
AS
BEGIN
    DECLARE @lv_BatchSize   	INT,
	        @lv_rowsMigrated 	INT,
			@lv_StartTime   	TIME,
            @lv_EndTime     	TIME,
			@lv_rowCount    	INT,
			@lv_headerRowCount	INT = 0,
			@lv_serviceRows 	INT = 0,
			@lv_bodyRowCount    INT = 0,
			@lv_eventRows   	INT = 0,
			@lv_headerRows  	INT = 0,
			@lv_bodyRows    	INT = 0,
			@lv_tagRefRows     	INT = 0,
            @lv_tagRows     	INT = 0,
			@lv_iteration   	INT = 0,
			@lv_bodyIteration   INT = 0,
			@lv_headerIteration INT = 0,
            @lv_replayRows  	INT = 0,
			@now 				DATETIME

	-- @now will be LST_UPDATED date of the record
	SET @now = GETDATE()

	-- Retention Days are mandatory
    IF (@p_retentionDays <= 0 OR @p_retentionDays IS NULL)
	BEGIN
	    RAISERROR('Invalid Retention Days specified',
		           16,
				   1);
		RETURN
	END

	-- Default batch size to 1000 if not provided

	IF (@p_batchSize <= 0 OR @p_batchSize IS NULL)
	BEGIN
	    SET @lv_BatchSize = 10000
    END
	ELSE
	BEGIN
	    SET @lv_BatchSize = @p_batchSize
	END

	-- Drop Temporary table if exists

	IF OBJECT_ID('tempdb.dbo.#messageBodiesToMigrate') IS NOT NULL
    BEGIN
		DROP TABLE [#messageBodiesToMigrate]
    END

	SET NOCOUNT ON
	SET @lv_StartTime = GETDATE()
	

	-- Migrate Referece Tables(Service and Tags)
	
	-- Migrate Data to Services  Table 
	INSERT INTO CONNECT_MS.MS_SRVC (SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST, D_DUP_KEY)
    SELECT DISTINCT MH.SRVC_TYPE, MH.SRVC_NAME, MH.SRVC_VER, MH.SRVC_INST, MH.SRVC_HOST , CONVERT(VARCHAR(256),HASHBYTES('SHA2_256',(MH.SRVC_TYPE + MH.SRVC_NAME + MH.SRVC_VER + MH.SRVC_INST + MH.SRVC_HOST + 'Messages')),2) 
    FROM dbo.MS_MSG_HDR MH WITH (NOLOCK)
	WHERE CAST(MH.LST_UPDT_AT AS DATE) > CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
    GROUP BY MH.SRVC_TYPE, MH.SRVC_NAME, MH.SRVC_VER, MH.SRVC_INST, MH.SRVC_HOST 

	-- Print number of rows migrated
    SET @lv_serviceRows = @@ROWCOUNT
    PRINT 'Rows migrated to Service Table: ' + CAST(@lv_serviceRows AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

    -- Migrate Tags
	SET IDENTITY_INSERT CONNECT_MS.MS_TAG ON

	INSERT INTO CONNECT_MS.MS_TAG (TAG_ID, TAG_NAME, CREATED_AT)
	SELECT (CAST(TAG_ID AS SMALLINT)), TAG_NAME, CREATED_AT
	FROM dbo.MS_TAG
	
	-- Print number of rows migrated
	SET @lv_tagRefRows = @@ROWCOUNT
	PRINT 'Rows Migrated from Tag Table ...' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

	SET IDENTITY_INSERT CONNECT_MS.MS_TAG OFF


	-- Migrate Transactional Tables 
	-- Migrate Bodies 
	
	-- Select body id's to be migrated into temp table
	SELECT msg_bdy_id
	  INTO #messageBodiesToMigrate
	  FROM dbo.MS_MSG_HDR MH WITH (NOLOCK)
	  WHERE CAST(MH.LST_UPDT_AT AS DATE) > CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
    ORDER BY msg_bdy_id;

	-- Print number of rows selected.
	SET @lv_bodyRowCount = @@ROWCOUNT
	PRINT 'Populated temp table with ' + CAST(@lv_bodyRowCount AS VARCHAR) + ' body keys to migrate. Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

	-- Break if nothing to migrate
	IF (@lv_bodyRowCount = 0)
	BEGIN
		PRINT 'There are no rows to migrate..'
		RETURN
	END
    
	-- Set IDENTITY INSERT ON as we will be inserting identities from source table
	SET IDENTITY_INSERT CONNECT_MS.MS_MSG_BDY ON

	-- Do Batches 
	BEGIN 
		WHILE (1 = 1)
		BEGIN

			-- Drop MessageToProcess Table for every run(This is temp table used for batching)
			IF OBJECT_ID('tempdb.dbo.#bodyToProcess') IS NOT NULL
			BEGIN
				DROP TABLE #bodyToProcess
			END

			BEGIN TRANSACTION

			-- Print Iteration number
			SET @lv_bodyIteration = @lv_bodyIteration + 1
			PRINT 'Body Iteration: ' + CAST(@lv_bodyIteration AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

			-- SELECT batch size into temporary table
			SELECT TOP (@lv_BatchSize) msg_bdy_id
			  INTO #bodyToProcess
			  FROM #messageBodiesToMigrate
			ORDER BY msg_bdy_id;
			SET @lv_rowCount = @@ROWCOUNT

			-- Print body keys with total time elapsed
			PRINT 'Loaded ' + CAST(@lv_rowCount AS VARCHAR) + ' body keys to Migrate. Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

			-- Check if we processed the complete dataset.
			IF (@lv_rowCount = 0)
			BEGIN
				-- No more rows for this iteration
				SET @lv_bodyIteration = @lv_bodyIteration - 1
				COMMIT TRANSACTION
				BREAK
			END
			
			-- Migrate Bodies 

			INSERT INTO CONNECT_MS.MS_MSG_BDY (MSG_BDY_ID, CRTD_AT, LST_UPDT_AT, MSG_FRMT, D_DUP_KEY, MSG_BDY, ACTIVE)
			SELECT (CAST(MSG_BDY_ID AS BIGINT)), CRTD_AT , @now, MSG_FRMT, (CAST(MSG_BDY_ID AS VARCHAR)), ((COMPRESS(CAST(MSG_BDY AS VARCHAR(MAX))))), 1
			FROM dbo.MS_MSG_BDY
			WHERE MSG_BDY_ID IN (SELECT msg_bdy_id FROM #bodyToProcess)
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_bodyRows = @lv_bodyRows + @lv_rowCount
			PRINT 'Rows Migrated from Body Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'


			-- Delete body keys from temp table holding all body keys to migrate.
			DELETE FROM #messageBodiesToMigrate
			 WHERE msg_bdy_id IN (SELECT msg_bdy_id
									FROM #bodyToProcess);

			SET @lv_rowsMigrated = @@ROWCOUNT

			COMMIT TRANSACTION

			-- Check if we processed the complete dataset
			IF @lv_rowsMigrated < @lv_BatchSize BREAK
		END 
	END 

	SET IDENTITY_INSERT CONNECT_MS.MS_MSG_BDY OFF

    
	
	-- Migrate Header and Service

    -- Select relevent header id's into temp table
	SELECT msg_hdr_id
	  INTO #messageHeadersToMigrate
	  FROM dbo.MS_MSG_HDR MS WITH (NOLOCK)
	  WHERE CAST(MS.LST_UPDT_AT AS DATE) > CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
    ORDER BY msg_hdr_id;


    -- Print the rows selected.
	SET @lv_headerRowCount = @@ROWCOUNT
	PRINT 'Populated temp table with ' + CAST(@lv_headerRowCount AS VARCHAR) + ' header keys to migrate.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

    -- Break if nothing to purge
	IF (@lv_headerRowCount = 0)
	BEGIN
		PRINT 'There are no rows to migrate..'
		RETURN
	END

	-- Do Batches
	BEGIN  -- (@lv_BatchSize > 0)
		WHILE (1 = 1)
		BEGIN

	        -- Drop HeaderToProcess Table for every run
			IF OBJECT_ID('tempdb.dbo.#headerToProcess') IS NOT NULL
			BEGIN
				DROP TABLE #headerToProcess
			END

			BEGIN TRANSACTION
			-- Print Iteration number
			SET @lv_headerIteration = @lv_headerIteration + 1
			PRINT 'Header Iteration: ' + CAST(@lv_headerIteration AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

	        -- SELECT batch size into temporary table
			SELECT TOP (@lv_BatchSize) msg_hdr_id
			  INTO #headerToProcess
			  FROM #messageHeadersToMigrate
			ORDER BY msg_hdr_id;
			SET @lv_rowCount = @@ROWCOUNT
			
			-- Print count of loaded keys
			PRINT 'Loaded ' + CAST(@lv_rowCount AS VARCHAR) + ' Header keys to Migrate.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR) + ' secs.'

	        -- Check if we processed the complete dataset.

			IF (@lv_rowCount = 0)
			BEGIN
				-- No more rows for this iteration
				SET @lv_headerIteration = @lv_headerIteration - 1
				COMMIT TRANSACTION
				BREAK
			END

            -- Set IDENTITY INSERT ON
            SET IDENTITY_INSERT CONNECT_MS.MS_MSG_HDR ON

            INSERT INTO CONNECT_MS.MS_MSG_HDR
            (MSG_HDR_ID,MSG_BDY_ID,SRVC_ID, CRTD_AT,LST_UPDT_AT,CRNT_STATUS,D_DUP_KEY,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,MSG_CAT,MSG_TYPE,MSG_VER,MSG_ID,MSG_SNDR,MSG_RCVRS,DOC_ID,DOC_CUST_ID,DOC_TMSTMP,REF_MSG_SNDR,REF_MSG_ID,REF_DOC_ID,TST_MSG)
            SELECT (CAST(MH.MSG_HDR_ID AS BIGINT)),(CAST(MH.MSG_BDY_ID AS BIGINT)),MS.SRVC_ID,MH.CRTD_AT,MH.LST_UPDT_AT,MH.CRNT_STATUS,MH.D_DUP_KEY,MH.END_PNT_TYPE,MH.END_PNT_NAME,MH.MDL_TYPE,MH.MSG_CAT,MH.MSG_TYPE,MH.MSG_VER,MH.MSG_ID,MH.MSG_SNDR,MH.MSG_RCVRS,MH.DOC_ID,MH.DOC_CUST_ID,MH.DOC_TMSTMP,MH.REF_MSG_SNDR,MH.REF_MSG_ID,MH.REF_DOC_ID,MH.TST_MSG
            FROM dbo.MS_MSG_HDR MH 
            JOIN CONNECT_MS.MS_SRVC MS
            ON CONVERT(VARCHAR(256),HASHBYTES('SHA2_256',(MH.SRVC_TYPE + MH.SRVC_NAME + MH.SRVC_VER + MH.SRVC_INST + MH.SRVC_HOST + 'Messages')),2) = MS.D_DUP_KEY
            WHERE MH.MSG_HDR_ID IN (SELECT msg_hdr_id FROM #headerToProcess) OPTION (RECOMPILE);

			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_headerRows = @lv_headerRows + @lv_rowCount
			PRINT 'Rows Migrated from Header Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR) + ' secs.'

            SET IDENTITY_INSERT CONNECT_MS.MS_MSG_HDR OFF

            -- Migrate EVENTS

			SET IDENTITY_INSERT CONNECT_MS.MS_MSG_EVNT ON

			INSERT INTO CONNECT_MS.MS_MSG_EVNT (MSG_EVNT_ID, MSG_HDR_ID, STATUS, CRTD_AT, ERR_CODE, ERR_DESC, ERR_CAT, ERR_REASON, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
			SELECT (CAST(MSG_EVNT_ID AS BIGINT)),(CAST(MSG_HDR_ID AS BIGINT)),STATUS, CRTD_AT, ERR_CODE, ERR_DESC, null, null, null, null, null
			FROM dbo.MS_MSG_EVNT ME
			WHERE ME.MSG_HDR_ID IN (SELECT msg_hdr_id FROM #headerToProcess) OPTION (RECOMPILE);
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_eventRows = @lv_eventRows + @lv_rowCount
			PRINT 'Rows Migrated from Event Table ...' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR) + ' secs.'

			SET IDENTITY_INSERT CONNECT_MS.MS_MSG_EVNT OFF


            -- Migrate Tags transactional data

			INSERT INTO CONNECT_MS.MS_MSG_TAG (TAG_ID, MSG_HDR_ID, CREATED_AT)
			SELECT (CAST(TAG_ID AS SMALLINT)), (CAST(MSG_HDR_ID AS BIGINT)), CREATED_AT
			FROM dbo.MS_MSG_TAG MT
			WHERE MT.MSG_HDR_ID IN (SELECT msg_hdr_id FROM #headerToProcess) OPTION (RECOMPILE);

			SET @lv_rowCount = @@ROWCOUNT
            SET @lv_tagRows = @lv_tagRows + @lv_rowCount
			PRINT 'Rows Migrated from MS_MSG_TAG Table ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR) + ' secs.'


            -- Migrate From Replayable Table 

			INSERT INTO CONNECT_MS.MS_RPLYBL_MSGS (CRTD_AT,LST_UPDT_AT,MSG_STORE_ID,RPLY_COUNT,NXT_RUN_AT,ACTIVE,RPLYNG)
			SELECT RM.CRTD_AT,RM.LST_UPDT_AT,RM.MSG_STORE_ID,RM.RPLY_COUNT,RM.NXT_RUN_AT,RM.ACTIVE,RM.RPLYNG
			FROM dbo.MS_RPLYBL_MSGS RM
			WHERE RM.MSG_STORE_ID IN (SELECT msg_hdr_id FROM #headerToProcess) OPTION (RECOMPILE);
    
            SET @lv_rowCount = @@ROWCOUNT
            SET @lv_replayRows = @lv_replayRows + @lv_rowCount
			PRINT 'Rows migrated from Replable Table ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR) + ' secs.'




            -- Delete from temporary table.
			DELETE FROM #messageHeadersToMigrate
			 WHERE msg_hdr_id IN (SELECT msg_hdr_id
			                        FROM #headerToProcess);

			SET @lv_rowsMigrated = @@ROWCOUNT

			COMMIT TRANSACTION

            -- Check if we processed the complete dataset
			IF @lv_rowsMigrated < @lv_BatchSize BREAK
		END -- WHILE (1 = 1)
	END -- (@lv_BatchSize > 0)
    SET @lv_EndTime = GETDATE()


    PRINT '----SUMMARY----'
    PRINT 'Start Time: ' + CAST(@lv_StartTime as VARCHAR)
	PRINT 'Servies Rows Created: ' + CAST(@lv_serviceRows AS VARCHAR)
	PRINT 'Tag Ref Rows Migrated: ' + CAST(@lv_tagRefRows AS VARCHAR)
	PRINT 'Total Body Iterations: ' + CAST(@lv_bodyIteration AS VARCHAR)
	PRINT 'Body Rows Migrated: ' + CAST(@lv_bodyRows AS VARCHAR)
	PRINT 'Total Header Iterations: ' + CAST(@lv_headerIteration AS VARCHAR)
	PRINT 'Header Rows Migrated: ' + CAST(@lv_headerRows AS VARCHAR)
	PRINT 'Event Rows Migrated: ' + CAST(@lv_eventRows AS VARCHAR)
    PRINT 'Replay Rows Migrated: ' + CAST(@lv_replayRows AS VARCHAR)
    PRINT 'Tag transactional Rows Migrated: ' + CAST(@lv_tagRows AS VARCHAR)
    PRINT 'End Time: ' + CAST(@lv_EndTime as VARCHAR)
    PRINT 'Total Time Taken: ' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_EndTime) AS VARCHAR) + ' secs.'
	SET NOCOUNT OFF
END
GO