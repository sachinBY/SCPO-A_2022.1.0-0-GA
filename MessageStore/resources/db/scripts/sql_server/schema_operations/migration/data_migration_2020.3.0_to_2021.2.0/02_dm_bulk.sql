SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [CONNECT_MS].[dataMigrationFrom2020300To2021200_Bulk]
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
			@lv_serviceRows 	INT = 0,
			@lv_bulkHeaderRowCount	INT = 0,
			@lv_bulkHeaderRows   	INT = 0,
			@lv_bulkEventRows  	INT = 0,
			@lv_bulkRecordHdrRows    	INT = 0,
			@lv_bulkRecordEvntRows     	INT = 0,
			@lv_iteration   	INT = 0,
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

	IF OBJECT_ID('tempdb.dbo.#BulkHdrToMigrate') IS NOT NULL
    BEGIN
		DROP TABLE [#BulkHdrToMigrate]
    END
	

	SET NOCOUNT ON
	SET @lv_StartTime = GETDATE()
	

	-- Migrate Referece Tables(Service and Tags)
	
	-- Migrate Data to Services  Table 
	
	INSERT INTO CONNECT_MS.MS_SRVC (SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST, D_DUP_KEY)
    SELECT DISTINCT BH.SRVC_TYPE, BH.SRVC_NAME, BH.SRVC_VER, BH.SRVC_INST, BH.SRVC_HOST , CONVERT(VARCHAR(256),HASHBYTES('SHA2_256',(BH.SRVC_TYPE + BH.SRVC_NAME + BH.SRVC_VER + BH.SRVC_INST + BH.SRVC_HOST + 'Bulk')),2) 
    FROM dbo.MS_BLK_HDR BH WITH (NOLOCK)
	WHERE CAST(BH.LST_UPDT_AT AS DATE) > CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE) 
    GROUP BY BH.SRVC_TYPE, BH.SRVC_NAME, BH.SRVC_VER, BH.SRVC_INST, BH.SRVC_HOST 

	-- Print number of rows migrated
    SET @lv_serviceRows = @@ROWCOUNT
    PRINT 'Rows migrated to Service Table: ' + CAST(@lv_serviceRows AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

	-- Select Bulk Headers to be migrated
	SELECT BLK_HDR_ID
		INTO #blkHdrToMIgrate
		FROM dbo.MS_BLK_HDR BH WITH (NOLOCK)
		WHERE CAST(BH.LST_UPDT_AT as DATE) > CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
	ORDER BY BLK_HDR_ID

	-- Print number of rows selected.
	SET @lv_bulkHeaderRowCount = @@ROWCOUNT
	PRINT 'Populated temp table with ' + CAST(@lv_bulkHeaderRowCount AS VARCHAR) + ' bulk header keys to migrate. Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

	
	-- Break if nothing to migrate
	IF (@lv_bulkHeaderRowCount = 0)
	BEGIN
		PRINT 'There are no rows to migrate..'
		RETURN
	END
	
	-- Do Batches 
	BEGIN 
		WHILE (1 = 1)
		BEGIN

			-- Drop BulkHeaderToProcess Table for every run(This is temp table used for batching)
			IF OBJECT_ID('tempdb.dbo.#blkHdrToProcess') IS NOT NULL
			BEGIN
				DROP TABLE #blkHdrToProcess
			END
			
			-- Drop BulkEventsToProcess Table for every run(This is temp table used for batching)
			IF OBJECT_ID('tempdb.dbo.#blkEvntsToProcess') IS NOT NULL
			BEGIN
				DROP TABLE #blkEvntsToProcess
			END

			BEGIN TRANSACTION

			-- Print Iteration number
			SET @lv_iteration = @lv_iteration + 1
			PRINT 'Body Iteration: ' + CAST(@lv_iteration AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

			-- SELECT batch size into temporary table
			SELECT TOP (@lv_BatchSize) BLK_HDR_ID
			  INTO #blkHdrToProcess
			  FROM #blkHdrToMIgrate
			ORDER BY BLK_HDR_ID;
			SET @lv_rowCount = @@ROWCOUNT

			-- Print body keys with total time elapsed
			PRINT 'Loaded ' + CAST(@lv_rowCount AS VARCHAR) + ' bulk header keys to Migrate. Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

			-- Check if we processed the complete dataset.
			IF (@lv_rowCount = 0)
			BEGIN
				-- No more rows for this iteration
				SET @lv_iteration = @lv_iteration - 1
				COMMIT TRANSACTION
				BREAK
			END
			
			-- Migrate Bulk Header
			
			SET IDENTITY_INSERT CONNECT_MS.MS_BLK_HDR ON

			INSERT INTO CONNECT_MS.MS_BLK_HDR (BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,CRNT_STATUS,SRVC_ID,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,BLK_ID,BLK_TYPE,BLK_VER,BLK_SRC,BLK_LOC,BLK_FORMAT,BLK_SRC_ID)
			SELECT BH.BLK_HDR_ID, BH.CRTD_AT, BH.LST_UPDT_AT, BH.CRNT_STATUS, MS.SRVC_ID, BH.END_PNT_TYPE, BH.END_PNT_NAME, BH.MDL_TYPE, BH.BLK_ID, BH.BLK_TYPE, BH.BLK_VER, BH.BLK_SRC, BH.BLK_LOC, BH.BLK_FORMAT, BH.BLK_SRC_ID
			FROM dbo.MS_BLK_HDR BH
			JOIN CONNECT_MS.MS_SRVC MS
            ON CONVERT(VARCHAR(256),HASHBYTES('SHA2_256',(BH.SRVC_TYPE + BH.SRVC_NAME + BH.SRVC_VER + BH.SRVC_INST + BH.SRVC_HOST + 'Bulk')),2) = MS.D_DUP_KEY
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM #blkHdrToProcess)
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_bulkHeaderRows = @lv_bulkHeaderRows + @lv_rowCount
			PRINT 'Rows Migrated from Bulk Header Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'
			
			SET IDENTITY_INSERT CONNECT_MS.MS_BLK_HDR OFF
			
			SET IDENTITY_INSERT CONNECT_MS.MS_BLK_EVNT ON
			
			INSERT into CONNECT_MS.MS_BLK_EVNT (BLK_EVNT_ID,BLK_HDR_ID,STATUS,CRTD_AT,BTCH_ID,BTCH_TASK,BTCH_TOT_REC,BTCH_PRC_REC,BTCH_SUC_REC,BTCH_FLD_REC,ERR_CODE,ERR_DESC,ERR_CAT,ERR_REASON,ERR_DETAIL_DESC)
			SELECT BLK_EVNT_ID,BLK_HDR_ID,STATUS,CRTD_AT,BTCH_ID,BTCH_TASK,BTCH_TOT_REC,BTCH_PRC_REC,BTCH_SUC_REC,BTCH_FLD_REC,ERR_CODE,ERR_DESC,null,null,null
			FROM dbo.MS_BLK_EVNT
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM #blkHdrToProcess)
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_bulkEventRows = @lv_bulkEventRows + @lv_rowCount
			PRINT 'Rows Migrated from Bulk Event Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'
			
			SET IDENTITY_INSERT CONNECT_MS.MS_BLK_EVNT OFF
			
			SET IDENTITY_INSERT CONNECT_MS.MS_RCRD_HDR ON
			
			INSERT INTO CONNECT_MS.MS_RCRD_HDR (BLK_RCRD_HDR_ID,BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,LST_TASK,CRNT_STATUS,RCRD_ID,SEQ_NO,RCRD_HDR_BODY)
			SELECT BLK_RCRD_HDR_ID,BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,LST_TASK,CRNT_STATUS,RCRD_ID,SEQ_NO,((COMPRESS(CAST(RCRD_HDR_BODY AS VARCHAR(MAX)))))
			FROM dbo.MS_RCRD_HDR
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM #blkHdrToProcess)
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_bulkRecordHdrRows = @lv_bulkRecordHdrRows + @lv_rowCount
			PRINT 'Rows Migrated from Bulk Record Header Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'
			
			SET IDENTITY_INSERT CONNECT_MS.MS_RCRD_HDR OFF
			
			-- Select Events to be migrated
			--SELECT BLK_RCRD_HDR_ID
			--  INTO #blkEvntsToProcess
			--  FROM dbo.MS_RCRD_HDR RH
			--Where RH.BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM #blkHdrToProcess)
			--SET @lv_rowCount = @@ROWCOUNT
		 
			---- Print body keys with total time elapsed
			--PRINT 'Loaded ' + CAST(@lv_rowCount AS VARCHAR) + ' bulk record event keys to Migrate. Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'
		  
			
			SET IDENTITY_INSERT CONNECT_MS.MS_RCRD_EVNT ON
			
			INSERT INTO CONNECT_MS.MS_RCRD_EVNT (BLK_RCRD_EVNT_ID,RCRD_HDR_ID,BLK_HDR_ID,TASK_NAME,TASK_ID,STATUS,CRTD_AT,ERR_CODE,ERR_DESC,ERR_CAT,ERR_REASON,ERR_DETAIL_DESC)
			SELECT EVNT.BLK_RCRD_EVNT_ID, EVNT.RCRD_HDR_ID, HDR.BLK_HDR_ID,EVNT.TASK_NAME, EVNT.TASK_ID, EVNT.STATUS, EVNT.CRTD_AT, EVNT.ERR_CODE, EVNT.ERR_DESC,null,null,null
			FROM dbo.MS_RCRD_EVNT EVNT
			JOIN dbo.MS_RCRD_HDR HDR
			ON HDR.BLK_RCRD_HDR_ID = EVNT.RCRD_HDR_ID
			WHERE HDR.BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM #blkHdrToProcess)
			
			-- Print number of rows migrated 
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_bulkRecordEvntRows = @lv_bulkRecordEvntRows + @lv_rowCount
			PRINT 'Rows Migrated from Bulk Record Event Table: ' + CAST(@lv_rowCount AS VARCHAR) + '.Total time elapsed: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)  + ' secs.'

			SET IDENTITY_INSERT CONNECT_MS.MS_RCRD_EVNT OFF

			-- Delete body keys from temp table holding all body keys to migrate.
			DELETE FROM #blkHdrToMIgrate
			 WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID
									FROM #blkHdrToProcess);

			SET @lv_rowsMigrated = @@ROWCOUNT

			COMMIT TRANSACTION

			-- Check if we processed the complete dataset
			IF @lv_rowsMigrated < @lv_BatchSize BREAK
		END 
	END 

    SET @lv_EndTime = GETDATE()


    PRINT '----SUMMARY----'
    PRINT 'Start Time: ' + CAST(@lv_StartTime as VARCHAR)
	PRINT 'Service Rows Migrated: ' + CAST(@lv_serviceRows AS VARCHAR)
	PRINT 'Bulk Header Rows Migrated: ' + CAST(@lv_bulkHeaderRows AS VARCHAR)
	PRINT 'Bulk Event Rows Migrated: ' + CAST(@lv_bulkEventRows AS VARCHAR)
	PRINT 'Bulk Record Header Rows Migrated: ' + CAST(@lv_bulkEventRows AS VARCHAR)
	PRINT 'Bulk Record Events Rows Migrated: ' + CAST(@lv_bulkRecordEvntRows AS VARCHAR)
	PRINT 'Total Iterations: ' + CAST(@lv_iteration AS VARCHAR)
    PRINT 'End Time: ' + CAST(@lv_EndTime as VARCHAR)
    PRINT 'Total Time Taken: ' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_EndTime) AS VARCHAR) + ' secs.'
	SET NOCOUNT OFF
END
GO