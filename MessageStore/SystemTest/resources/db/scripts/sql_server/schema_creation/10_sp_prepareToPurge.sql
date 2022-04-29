:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).[prepareToPurge]
(
  @p_retentionDays INT,
  @p_batchSize    INT,
  @o_purgeId   INT OUTPUT,
  @o_outputSummary  VARCHAR(2048) OUTPUT
 
)
AS
BEGIN
  DECLARE 
  @lv_BatchSize		INT,
  @lv_rowCount    	INT,
  @lv_StartTime   	TIME,
  @lv_EndTime     	DATETIME,			
  @lv_headerRows  	INT = 0,
  @lv_HeaderEndTime 	TIME,
  @lv_HeaderIteration	INT = 0,
  @lv_bodyRows    	INT = 0,
  @lv_BodyEndTime 	TIME,
  @lv_BodyIteration	INT = 0,
  @Processed      	BINARY,

  @v_purgeId		INT,
  @v_stepStartTime	DATETIME,
  @lv_StartTimeUc   	DATETIME,
  @lv_HeaderEndTimeUc 	DATETIME,
  @lv_BodyEndTimeUc 	DATETIME


-- Retention Days are mandatory
    IF (@p_retentionDays <= 0 OR @p_retentionDays IS NULL)
	BEGIN
	    RAISERROR('Invalid Retention Days specified',16,1);
	    RETURN
	END

-- Default batch size to 1000 if not provided
  IF (@p_batchSize < 0 OR @p_batchSize IS NULL)
    BEGIN
      SET @lv_BatchSize = 1000
    END
  ELSE
    BEGIN
      SET @lv_BatchSize = @p_batchSize
    END

  SET NOCOUNT ON
  SET @lv_StartTimeUc = GETDATE()
  SET @lv_StartTime = CAST(@lv_StartTimeUc AS TIME)

  SET @v_purgeId = NEXT VALUE FOR PURGE_JOB_SEQ
  SET @o_purgeId = @v_purgeId

  BEGIN  -- (@lv_BatchSize > 0)
    WHILE (1 = 1)
      BEGIN
        BEGIN TRANSACTION
		
        SET @v_stepStartTime = GETDATE()
				
        UPDATE TOP (@lv_BatchSize) MS_MSG_HDR
          SET ACTIVE = 0
          WHERE 
          CAST(LST_UPDT_AT AS DATE) < CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
          AND ACTIVE = 1
			
        SET @lv_rowCount = @@ROWCOUNT
        SET @lv_headerRows = @lv_headerRows + @lv_rowCount
        SET @lv_HeaderIteration = @lv_HeaderIteration + 1
			
        PRINT 'Rows Updated in Header Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)
				
        INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (@v_purgeId,@v_stepStartTime, GETDATE(),'STEP - UPDATE MS_MSG_HDR STATUS', @lv_rowCount);
			
        IF (@lv_rowCount = 0 OR @lv_rowCount < @lv_BatchSize)
          BEGIN
            -- No more rows for this iteration
            -- SET @lv_iteration = @lv_iteration - 1
            COMMIT TRANSACTION
            BREAK
          END
        COMMIT TRANSACTION
       END
    
       SET @lv_HeaderEndTimeUc = GETDATE()
       SET @lv_HeaderEndTime = CAST(@lv_HeaderEndTimeUc AS TIME)
       
       PRINT 'Updated Header table' + CAST(@lv_HeaderEndTime as VARCHAR)
       PRINT 'Rows Updated in Body Table ...' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)
	
       -- Updating Body Table
       -- Set Processed For Body Updates
       SELECT @Processed=COMPRESS ('PROCESSED') ;
      END
	
    -- Drop Temporary table if exists
    IF OBJECT_ID('tempdb.dbo.#messageBodyToBeInactivated') IS NOT NULL
      BEGIN
        DROP TABLE [#messageBodyToBeInactivated]
      END

    SELECT DISTINCT (MSG_BDY_ID)
	INTO #messageBodyToBeInactivated
	FROM MS_MSG_HDR MH WITH (NOLOCK) 
	WHERE ACTIVE = 0
	AND NOT EXISTS (SELECT 1 FROM MS_MSG_HDR MHI where ACTIVE = 1 AND MHI.MSG_BDY_ID = MH.MSG_BDY_ID )
	
	BEGIN
          WHILE (1 = 1)
            BEGIN

            SET @v_stepStartTime = GETDATE()
            IF OBJECT_ID('tempdb.dbo.#bodyToProcess') IS NOT NULL
              BEGIN
                DROP TABLE #bodyToProcess
              END
		
	    BEGIN TRANSACTION

	      SELECT TOP (@lv_BatchSize) MSG_BDY_ID 
	        INTO #bodyToProcess
	        FROM #messageBodyToBeInactivated
	        ORDER BY MSG_BDY_ID;
				
	      SET @lv_rowCount = @@ROWCOUNT
		
	      PRINT 'Loaded...' + CAST(@lv_rowCount AS VARCHAR) + ' body keys to be inactivated, Time Taken(in seconds) till now : ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

	      UPDATE MS_MSG_BDY
	        SET ACTIVE = 0
	        WHERE 
	        MSG_BDY_ID IN (SELECT MSG_BDY_ID FROM #bodyToProcess) OPTION (RECOMPILE);
				
	      SET @lv_rowCount = @@ROWCOUNT
	      SET @lv_bodyRows = @lv_bodyRows + @lv_rowCount
	      SET @lv_BodyIteration = @lv_BodyIteration + 1
	      PRINT 'Rows Updated in Body Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

	      INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (@v_purgeId,@v_stepStartTime, GETDATE(),'STEP - UPDATE MS_MSG_BDY STATUS', @lv_rowCount);
		  

	      IF (@lv_rowCount = 0 OR @lv_rowCount < @lv_BatchSize)
	        BEGIN
	          -- No more rows for this iteration
	          -- SET @lv_iteration = @lv_iteration - 1
	          COMMIT TRANSACTION
	          BREAK
	        END
	        
	-- Delete from temporary table.
	DELETE FROM #messageBodyToBeInactivated
	WHERE msg_bdy_id IN (SELECT msg_bdy_id
	  FROM #bodyToProcess);
	COMMIT TRANSACTION
	END
	  SET @lv_BodyEndTimeUc = GETDATE()
	  SET @lv_BodyEndTime = CAST(@lv_BodyEndTimeUc AS TIME)
	END
	PRINT 'Rows Updated in Body Table ...' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)


	SET @lv_EndTime = GETDATE()

	PRINT '----SUMMARY----'
	PRINT 'Start Time' + CAST(@lv_StartTime as VARCHAR)
	PRINT 'End Time' + CAST(@lv_BodyEndTime as VARCHAR)
	PRINT 'Total time taken' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_BodyEndTime) AS VARCHAR)
	PRINT 'Rows Updated in Header Table : ' + CAST(@lv_headerRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_HeaderEndTime) AS VARCHAR)
	PRINT 'Total Header Iterations:' + CAST(@lv_HeaderIteration AS VARCHAR)
	PRINT 'Rows Updated in Body Table : ' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_HeaderEndTime, @lv_BodyEndTime) AS VARCHAR)
	PRINT 'Total Body Iterations:' + CAST(@lv_BodyIteration AS VARCHAR)
	
	BEGIN TRANSACTION
	INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC) VALUES (@v_purgeId,@lv_StartTimeUc, @lv_EndTime,'SUMMARY - PREPARE PURGE');
	INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT,ITERATION) VALUES (@v_purgeId,@lv_StartTimeUc, @lv_HeaderEndTimeUc,'SUMMARY - ROWS UPDATED IN MS_MSG_HDR', @lv_headerRows,@lv_headerIteration);
	INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT,ITERATION) VALUES (@v_purgeId,@lv_HeaderEndTimeUc, @lv_BodyEndTimeUc,'SUMMARY - ROWS UPDATED IN MS_MSG_BDY', @lv_bodyRows,@lv_BodyIteration);
	COMMIT TRANSACTION
	
	SET @o_outputSummary = 'SUMMARY - PREPARE PURGE. PurgeId - ' + CAST(@v_purgeId AS VARCHAR) + ' , Start Time - ' + CAST(@lv_StartTimeUc AS VARCHAR) + ' , EndTime - ' + CAST(@lv_EndTime AS VARCHAR) + ' , ROWS UPDATED IN MS_MSG_HDR - ' + CAST( @lv_headerRows AS VARCHAR) +  ' , ROWS UPDATED IN MS_MSG_BDY - ' + CAST(@lv_bodyRows AS VARCHAR);
	PRINT  'o_outputSummary - ' + @o_outputSummary
	

	SET NOCOUNT OFF
END
GO