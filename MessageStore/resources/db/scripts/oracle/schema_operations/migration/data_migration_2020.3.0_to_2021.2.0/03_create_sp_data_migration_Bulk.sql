--- when specifying the SOURCE_USER we should provide the dot(.) at the end of the SOURCE_USER in POPUP. 
--- Where SOURCE_USER is that from where Data should be migrated
DEFINE SOURCE_USER = '&SOURCE_USER';
DEFINE SCHEMAOWNER = 'CONNECT_MS.';

DROP TABLE &SCHEMAOWNER.blkHdrToMIgrate cascade CONSTRAINTS;
DROP TABLE &SCHEMAOWNER.blkHdrToProcess cascade CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.blkHdrToMIgrate (BLK_HDR_ID NUMBER) ON COMMIT PRESERVE ROWS;
CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.blkHdrToProcess (BLK_HDR_ID NUMBER) ON COMMIT PRESERVE ROWS;

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.dataMigrationFrom2020300To2021200_Bulk
(
	p_retentionDays    NUMBER,
	p_batchSize    NUMBER
)
AS
    lv_BatchSize   		NUMBER := 0;
	lv_rowsMigrated 	NUMBER := 0;
	lv_StartTime   		DATE;
	lv_EndTime     		DATE;
	lv_rowCount    		NUMBER := 0;
	lv_bulkHeaderRowCount	NUMBER := 0;
	lv_bulkHeaderRows   	NUMBER := 0;
	lv_bulkEventRows  		NUMBER := 0;
	lv_bulkRecordHdrRows    NUMBER := 0;
	lv_bulkRecordEvntRows   NUMBER := 0;
	lv_iteration   			NUMBER := 0;
	lv_serviceRows          NUMBER := 0;
BEGIN
	
	-- Retention Days are mandatory
    IF p_retentionDays <= 0 OR p_retentionDays IS NULL THEN
		BEGIN
			raise_application_error(16, 'Invalid Retention Days specified');
			RETURN;
		END;
	END IF;
	-- Default batch size to 1000 if not provided

	IF p_batchSize <= 0 OR p_batchSize IS NULL THEN
		BEGIN
			lv_BatchSize := 10000;
		END;
	ELSE
		BEGIN
			lv_BatchSize := p_batchSize;
		END;
	END IF;

	lv_StartTime := SYSDATE;
	
	INSERT INTO &SCHEMAOWNER.MS_SRVC (SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST, D_DUP_KEY)
    SELECT DISTINCT BH.SRVC_TYPE, BH.SRVC_NAME, BH.SRVC_VER, BH.SRVC_INST, BH.SRVC_HOST , STANDARD_HASH(BH.SRVC_TYPE || BH.SRVC_NAME || BH.SRVC_VER || BH.SRVC_INST || BH.SRVC_HOST || 'Bulk') 
    FROM &SOURCE_USER.MS_BLK_HDR BH
	WHERE CAST(BH.LST_UPDT_AT AS DATE) > CAST((SYSDATE - p_retentionDays) AS DATE)
    GROUP BY BH.SRVC_TYPE, BH.SRVC_NAME, BH.SRVC_VER, BH.SRVC_INST, BH.SRVC_HOST;
	
	lv_serviceRows := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
	dbms_output.put_line('Populated temp table with ' || CAST(lv_serviceRows AS VARCHAR2) || ' bulk header keys to migrate. Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

	-- Select Bulk Headers to be migrated
	INSERT INTO &SCHEMAOWNER.blkHdrToMIgrate(BLK_HDR_ID) SELECT BLK_HDR_ID FROM &SOURCE_USER.MS_BLK_HDR BLH 
	WHERE CAST(BLH.LST_UPDT_AT AS DATE) > CAST((SYSDATE - p_retentionDays) AS DATE)
	ORDER BY BLK_HDR_ID;

	-- Print number of rows selected.
	lv_bulkHeaderRowCount := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
	dbms_output.put_line('Populated temp table with ' || CAST(lv_bulkHeaderRowCount AS VARCHAR2) || ' bulk header keys to migrate. Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
	
	-- Break if nothing to migrate
	IF lv_bulkHeaderRowCount = 0 THEN
		BEGIN
			dbms_output.put_line('There are no rows to migrate..');
			RETURN;
		END;
	END IF;
	
	-- Do Batches 

	WHILE (1 = 1)
	LOOP
		BEGIN

			-- Print Iteration number
			lv_iteration := lv_iteration + 1;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Body Iteration: ' || CAST(lv_iteration AS VARCHAR2) || '. Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
			
			-- SELECT batch size into temporary table
			INSERT INTO &SCHEMAOWNER.blkHdrToProcess(BLK_HDR_ID) SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToMIgrate ORDER BY BLK_HDR_ID;
			
			lv_rowCount := SQL%ROWCOUNT;

			-- Print body keys with total time elapsed
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Loaded ' || CAST(lv_rowCount AS VARCHAR2) || ' bulk header keys to Migrate. Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

			-- Check if we processed the complete dataset.
			IF lv_rowCount = 0 THEN
				BEGIN
					-- No more rows for this iteration
					lv_iteration := lv_iteration - 1;
					COMMIT;
					RETURN;
				END;
			END IF;
			-- Migrate Bulk Header

			INSERT INTO &SCHEMAOWNER.MS_BLK_HDR (BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,CRNT_STATUS,SRVC_ID,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,BLK_ID,BLK_TYPE,BLK_VER,BLK_SRC,BLK_LOC,BLK_FORMAT,BLK_SRC_ID)
			SELECT BH.BLK_HDR_ID, BH.CRTD_AT, BH.LST_UPDT_AT, BH.CRNT_STATUS, MS.SRVC_ID, BH.END_PNT_TYPE, BH.END_PNT_NAME, BH.MDL_TYPE, BH.BLK_ID, BH.BLK_TYPE, BH.BLK_VER, BH.BLK_SRC, BH.BLK_LOC, BH.BLK_FORMAT, BH.BLK_SRC_ID
			FROM &SOURCE_USER.MS_BLK_HDR BH
			JOIN &SCHEMAOWNER.MS_SRVC MS
            ON STANDARD_HASH(BH.SRVC_TYPE || BH.SRVC_NAME || BH.SRVC_VER || BH.SRVC_INST || BH.SRVC_HOST || 'Bulk') = MS.D_DUP_KEY
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToProcess);
			
			
			-- Print number of rows migrated 
			lv_rowCount := SQL%ROWCOUNT;
			lv_bulkHeaderRows := lv_bulkHeaderRows + lv_rowCount;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Rows Migrated from Bulk Header Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
			
		
			INSERT into &SCHEMAOWNER.MS_BLK_EVNT (BLK_EVNT_ID,BLK_HDR_ID,STATUS,CRTD_AT,BTCH_ID,BTCH_TASK,BTCH_TOT_REC,BTCH_PRC_REC,BTCH_SUC_REC,BTCH_FLD_REC,ERR_CODE,ERR_DESC,ERR_CAT,ERR_REASON,ERR_DETAIL_DESC)
			SELECT BLK_EVNT_ID,BLK_HDR_ID,STATUS,CRTD_AT,BTCH_ID,BTCH_TASK,BTCH_TOT_REC,BTCH_PRC_REC,BTCH_SUC_REC,BTCH_FLD_REC,ERR_CODE,ERR_DESC,null,null,null
			FROM &SOURCE_USER.MS_BLK_EVNT
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToProcess);
			
			-- Print number of rows migrated 
			lv_rowCount := SQL%ROWCOUNT;
			lv_bulkEventRows := lv_bulkEventRows + lv_rowCount;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Rows Migrated from Bulk Event Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
						
			INSERT INTO &SCHEMAOWNER.MS_RCRD_HDR (BLK_RCRD_HDR_ID,BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,LST_TASK,CRNT_STATUS,RCRD_ID,SEQ_NO,RCRD_HDR_BODY)
			SELECT BLK_RCRD_HDR_ID,BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,LST_TASK,CRNT_STATUS,RCRD_ID,SEQ_NO, utl_compress.lz_compress(clob_to_blob(RCRD_HDR_BODY))
			FROM &SOURCE_USER.MS_RCRD_HDR
			WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToProcess);
			
			-- Print number of rows migrated 
			lv_rowCount := SQL%ROWCOUNT;
			lv_bulkRecordHdrRows := lv_bulkRecordHdrRows + lv_rowCount;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Rows Migrated from Bulk Record Header Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
			
			INSERT INTO &SCHEMAOWNER.MS_RCRD_EVNT (BLK_RCRD_EVNT_ID,RCRD_HDR_ID,BLK_HDR_ID,TASK_NAME,TASK_ID,STATUS,CRTD_AT,ERR_CODE,ERR_DESC,ERR_CAT,ERR_REASON,ERR_DETAIL_DESC)
			SELECT EVNT.BLK_RCRD_EVNT_ID, EVNT.RCRD_HDR_ID, HDR.BLK_HDR_ID,EVNT.TASK_NAME, EVNT.TASK_ID, EVNT.STATUS, EVNT.CRTD_AT, EVNT.ERR_CODE, EVNT.ERR_DESC,null,null,null
			FROM &SOURCE_USER.MS_RCRD_EVNT EVNT
			JOIN &SOURCE_USER.MS_RCRD_HDR HDR
			ON HDR.BLK_RCRD_HDR_ID = EVNT.RCRD_HDR_ID
			WHERE HDR.BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToProcess);
			
			
			-- Print number of rows migrated 
			lv_rowCount := SQL%ROWCOUNT;
			lv_bulkRecordEvntRows := lv_bulkRecordEvntRows + lv_rowCount;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Rows Migrated from Bulk Record Event Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

			-- Delete body keys from temp table holding all body keys to migrate.
			DELETE FROM &SCHEMAOWNER.blkHdrToMIgrate
			 WHERE BLK_HDR_ID IN (SELECT BLK_HDR_ID FROM &SCHEMAOWNER.blkHdrToProcess);

			lv_rowsMigrated := SQL%ROWCOUNT;

			COMMIT;

			-- Check if we processed the complete dataset
			IF lv_rowsMigrated < lv_BatchSize THEN
				EXIT;
			END IF;	
		END;
	END LOOP;
	
    lv_EndTime := SYSDATE;

	dbms_output.put_line('----SUMMARY----') ;
	dbms_output.put_line('Start Time: ' || CAST(lv_StartTime as VARCHAR2)) ;
	dbms_output.put_line('Service Rows Migrated: ' || CAST(lv_serviceRows AS VARCHAR));
	dbms_output.put_line('Bulk Header Rows Migrated: ' || CAST(lv_bulkHeaderRows AS VARCHAR2)) ;
	dbms_output.put_line('Bulk Event Rows Migrated: ' || CAST(lv_bulkEventRows AS VARCHAR2)) ;
	dbms_output.put_line('Bulk Record Header Rows Migrated: ' || CAST(lv_bulkEventRows AS VARCHAR2)) ;
	dbms_output.put_line('Bulk Record Events Rows Migrated: ' || CAST(lv_bulkRecordEvntRows AS VARCHAR2)) ;
	dbms_output.put_line('Total Iterations: ' || CAST(lv_iteration AS VARCHAR2)) ;
	dbms_output.put_line('End Time: ' || CAST(lv_EndTime as VARCHAR2)) ;
	dbms_output.put_line('Total Time Taken: ' || CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
	
END;
