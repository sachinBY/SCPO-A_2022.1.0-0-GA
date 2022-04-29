DEFINE SOURCE_USER = '&SOURCE_USER';
DEFINE SCHEMAOWNER = 'CONNECT_MS.';

DROP TABLE &SCHEMAOWNER.messageBodiesToMigrate;
DROP TABLE &SCHEMAOWNER.bodyToProcess;
DROP TABLE &SCHEMAOWNER.messageHeadersToMigrate;
DROP TABLE &SCHEMAOWNER.headerToProcess;

CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.messageBodiesToMigrate (msg_bdy_id VARCHAR2(100)) ON COMMIT PRESERVE ROWS;
CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.bodyToProcess (msg_bdy_id VARCHAR2(100)) ON COMMIT PRESERVE ROWS;
CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.messageHeadersToMigrate (msg_hdr_id VARCHAR2(100)) ON COMMIT PRESERVE ROWS;
CREATE GLOBAL TEMPORARY TABLE &SCHEMAOWNER.headerToProcess(msg_hdr_id VARCHAR2(100)) ON COMMIT PRESERVE ROWS;

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.dataMigrationFrom2020300To2021200_Messages
(
	p_retentionDays    NUMBER,
	p_batchSize    NUMBER
)
AS
	lv_BatchSize   	NUMBER;
	lv_rowsMigrated 	NUMBER;
	lv_StartTime   	DATE;
	lv_EndTime     	DATE;
	lv_rowCount    	NUMBER;
	lv_headerRowCount	NUMBER := 0;
	lv_serviceRows 	NUMBER := 0;
	lv_bodyRowCount    NUMBER := 0;
	lv_eventRows   	NUMBER := 0;
	lv_headerRows  	NUMBER := 0;
	lv_bodyRows    	NUMBER := 0;
	lv_tagRefRows     	NUMBER := 0;
	lv_tagRows     	NUMBER := 0;
	lv_iteration   	NUMBER := 0;
	lv_bodyIteration   NUMBER := 0;
	lv_headerIteration NUMBER := 0;
	lv_replayRows  	NUMBER := 0;
	currentDateTime  TIMESTAMP;
	
BEGIN
	-- currentDateTime will be LST_UPDATED date of the record
	 currentDateTime := SYSDATE;

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

	-- Drop Temporary table if exists

	
	lv_StartTime := SYSDATE;
	

	-- Migrate Referece Tables(Service and Tags)
	
	-- Migrate Data to Services  Table 
	INSERT INTO &SCHEMAOWNER.MS_SRVC (SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST, D_DUP_KEY)
    SELECT DISTINCT MH.SRVC_TYPE, MH.SRVC_NAME, MH.SRVC_VER, MH.SRVC_INST, MH.SRVC_HOST , STANDARD_HASH(MH.SRVC_TYPE || MH.SRVC_NAME || MH.SRVC_VER || MH.SRVC_INST || MH.SRVC_HOST || 'Messages')
    FROM &SOURCE_USER.MS_MSG_HDR MH
	WHERE CAST(MH.LST_UPDT_AT AS DATE) > CAST((SYSDATE - p_retentionDays) AS DATE)
    GROUP BY MH.SRVC_TYPE, MH.SRVC_NAME, MH.SRVC_VER, MH.SRVC_INST, MH.SRVC_HOST;

	-- Print number of rows migrated
    lv_serviceRows := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
    dbms_output.put_line('Rows migrated to Service Table: ' || CAST(lv_serviceRows AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

    -- Migrate Tags
	--  IDENTITY_INSERT &SCHEMAOWNER.MS_TAG ON

	INSERT INTO &SCHEMAOWNER.MS_TAG (TAG_ID, TAG_NAME, CREATED_AT)
	SELECT (CAST(TAG_ID AS SMALLINT)), TAG_NAME, CREATED_AT
	FROM &SOURCE_USER.MS_TAG;
	
	-- Print number of rows migrated
	lv_tagRefRows := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
    dbms_output.put_line('Rows Migrated from Tag Table ...' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;


	-- Migrate Transactional Tables 
	-- Migrate Bodies 
	
	-- Select body id's to be migrated into temp table
	INSERT INTO &SCHEMAOWNER.messageBodiesToMigrate(msg_bdy_id)
	SELECT msg_bdy_id FROM &SOURCE_USER.MS_MSG_HDR MH WHERE CAST(MH.LST_UPDT_AT AS DATE) > CAST((SYSDATE - p_retentionDays) AS DATE)
    ORDER BY msg_bdy_id;
	

	-- Print number of rows selected.
	lv_bodyRowCount := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
    dbms_output.put_line('Populated temp table messageBodiesToMigrate with  ' || CAST(lv_bodyRowCount AS VARCHAR2) || 'body keys to migrate. Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

	-- Break if nothing to migrate
	IF lv_bodyRowCount = 0 THEN
        BEGIN
            dbms_output.put_line('There are no rows to migrate..');
            RETURN;
        END;
    END If;
    
	-- Set IDENTITY INSERT ON as we will be inserting identities from source table
	-- IDENTITY_INSERT &SCHEMAOWNER.MS_MSG_BDY ON

	-- Do Batches 
	
	WHILE (1 =1)
    LOOP
        BEGIN
			-- Print Iteration number
			lv_bodyIteration := lv_bodyIteration + 1;
			lv_EndTime := SYSDATE;
            dbms_output.put_line('Body Iteration: ' || CAST(lv_bodyIteration AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

			-- SELECT batch size into temporary table
			
			INSERT INTO &SCHEMAOWNER.bodyToProcess(msg_bdy_id)
            SELECT msg_bdy_id
            FROM &SCHEMAOWNER.messageBodiesToMigrate
            ORDER BY &SCHEMAOWNER.messageBodiesToMigrate.msg_bdy_id
            FETCH NEXT lv_BatchSize ROWS ONLY;

			lv_rowCount := SQL%ROWCOUNT;
			-- Print body keys with total time elapsed
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Loaded ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

			-- Check if we processed the complete dataset.
			IF lv_rowCount = 0 THEN
                BEGIN
                    -- No more rows for this iteration
                    lv_bodyIteration := lv_bodyIteration - 1;
                    COMMIT;
                    EXIT;
                END;
            END IF;
			-- Migrate Bodies 
			
			INSERT INTO &SCHEMAOWNER.MS_MSG_BDY("MSG_BDY_ID", "CRTD_AT", "LST_UPDT_AT", "MSG_FRMT", "D_DUP_KEY", "MSG_BDY", "ACTIVE")
			SELECT CAST(MSB.MSG_BDY_ID AS NUMBER), MSB.CRTD_AT, currentDateTime, MSB.MSG_FRMT, CAST(MSB.MSG_BDY_ID AS VARCHAR2(20)),utl_compress.lz_compress(clob_to_blob(MSG_BDY)), 1  FROM &SOURCE_USER.MS_MSG_BDY MSB
            WHERE MSB.MSG_BDY_ID IN (SELECT msg_bdy_id FROM &SCHEMAOWNER.bodyToProcess);
			
			-- Print number of rows migrated 
			lv_rowCount := SQL%ROWCOUNT;
			lv_bodyRows := lv_bodyRows + lv_rowCount;
			lv_EndTime := SYSDATE;
			dbms_output.put_line('Rows Migrated from Body Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

			-- Delete body keys from temp table holding all body keys to migrate.								
			DELETE FROM &SCHEMAOWNER.messageBodiesToMigrate WHERE msg_bdy_id IN (SELECT msg_bdy_id FROM &SCHEMAOWNER.bodyToProcess);

			lv_rowsMigrated := SQL%ROWCOUNT;

			COMMIT;

			-- Check if we processed the complete dataset
			IF lv_rowsMigrated < lv_BatchSize THEN 
                EXIT;
            END IF;
		END;
	END LOOP;

	-- IDENTITY_INSERT &SCHEMAOWNER.MS_MSG_BDY OFF

    -- Migrate Header and Service

    -- Select relevent header id's into temp table

	INSERT INTO &SCHEMAOWNER.messageHeadersToMigrate(msg_hdr_id)
	SELECT MSG_HDR_ID FROM &SOURCE_USER.MS_MSG_HDR MS
	WHERE CAST(MS.LST_UPDT_AT AS DATE) > CAST((SYSDATE - p_retentionDays) AS DATE)
    ORDER BY msg_hdr_id;
	
	-- Print the rows selected.
	lv_headerRowCount := SQL%ROWCOUNT;
	lv_EndTime := SYSDATE;
	dbms_output.put_line('Populated temp table messageHeadersToMigrate with ' || CAST(lv_headerRowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

    -- Break if nothing to purge
	IF lv_headerRowCount = 0 THEN
        BEGIN
            dbms_output.put_line('There are no rows to migrate..');
            RETURN;
        END;
    END IF;    

	-- Do Batches
	BEGIN  -- (@lv_BatchSize > 0)
		WHILE (1 = 1)
		LOOP
			BEGIN

				-- Print Iteration number
				lv_headerIteration := lv_headerIteration + 1;
				lv_EndTime := SYSDATE;
                dbms_output.put_line('Header Iteration:  ' || CAST(lv_headerIteration AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

				-- SELECT batch size into temporary table
				INSERT INTO &SCHEMAOWNER.headerToProcess(msg_hdr_id)
                SELECT msg_hdr_id FROM &SCHEMAOWNER.messageHeadersToMigrate
                ORDER BY msg_hdr_id;
                
                lv_rowCount := SQL%ROWCOUNT;
				
				-- Print count of loaded keys
				lv_EndTime := SYSDATE;
                dbms_output.put_line('Loaded  ' || CAST(lv_headerIteration AS VARCHAR2) || 'Header keys to Migrate.Total time elapsed:  ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

				-- Check if we processed the complete dataset.
				IF lv_rowCount = 0 THEN
                    BEGIN
                        -- No more rows for this iteration
                        lv_headerIteration := lv_headerIteration - 1;
                        COMMIT;
                        EXIT;
                    END;
                END IF;

				INSERT INTO &SCHEMAOWNER.MS_MSG_HDR
                (MSG_HDR_ID,MSG_BDY_ID,SRVC_ID, CRTD_AT,LST_UPDT_AT,CRNT_STATUS,D_DUP_KEY,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,MSG_CAT,MSG_TYPE,MSG_VER,MSG_ID,MSG_SNDR,MSG_RCVRS,DOC_ID,DOC_CUST_ID,DOC_TMSTMP,REF_MSG_SNDR,REF_MSG_ID,REF_DOC_ID,TST_MSG)
                SELECT (CAST(MH.MSG_HDR_ID AS NUMBER)),(CAST(MH.MSG_BDY_ID AS NUMBER)),MS.SRVC_ID,MH.CRTD_AT,MH.LST_UPDT_AT,MH.CRNT_STATUS,MH.D_DUP_KEY,MH.END_PNT_TYPE,MH.END_PNT_NAME,MH.MDL_TYPE,MH.MSG_CAT,MH.MSG_TYPE,MH.MSG_VER,MH.MSG_ID,MH.MSG_SNDR,MH.MSG_RCVRS,MH.DOC_ID,MH.DOC_CUST_ID,MH.DOC_TMSTMP,MH.REF_MSG_SNDR,MH.REF_MSG_ID,MH.REF_DOC_ID,MH.TST_MSG
                FROM &SOURCE_USER.MS_MSG_HDR MH 
                JOIN &SCHEMAOWNER.MS_SRVC MS
                ON STANDARD_HASH(MH.SRVC_TYPE || MH.SRVC_NAME || MH.SRVC_VER || MH.SRVC_INST || MH.SRVC_HOST || 'Messages') = MS.D_DUP_KEY
                WHERE MH.MSG_HDR_ID IN (SELECT msg_hdr_id FROM &SCHEMAOWNER.headerToProcess);
				
				
				-- Print number of rows migrated 
				lv_rowCount := SQL%ROWCOUNT;
                lv_headerRows := lv_headerRows + lv_rowCount;
				lv_EndTime := SYSDATE;
                dbms_output.put_line('Rows Migrated from Header Table: ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

				-- Migrate EVENTS
	
				INSERT INTO &SCHEMAOWNER.MS_MSG_EVNT (MSG_EVNT_ID, MSG_HDR_ID, STATUS, CRTD_AT, ERR_CODE, ERR_DESC, ERR_CAT, ERR_REASON, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
                SELECT (CAST(MSG_EVNT_ID AS NUMBER)),(CAST(MSG_HDR_ID AS NUMBER)),STATUS, CRTD_AT, ERR_CODE, ERR_DESC, null, null, null, null, null
                FROM &SOURCE_USER.MS_MSG_EVNT ME
                WHERE ME.MSG_HDR_ID IN (SELECT msg_hdr_id FROM &SCHEMAOWNER.headerToProcess);
				
				-- Print number of rows migrated 
                lv_rowCount := SQL%ROWCOUNT;
                lv_eventRows := lv_eventRows + lv_rowCount;
				lv_EndTime := SYSDATE;
                dbms_output.put_line('Rows Migrated from Event Table ... ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;

				-- Migrate Tags transactional data

				INSERT INTO &SCHEMAOWNER.MS_MSG_TAG (TAG_ID, MSG_HDR_ID, CREATED_AT)
                SELECT (CAST(TAG_ID AS SMALLINT)), (CAST(MSG_HDR_ID AS NUMBER)), CREATED_AT
                FROM &SOURCE_USER.MS_MSG_TAG MT
                WHERE MT.MSG_HDR_ID IN (SELECT msg_hdr_id FROM &SCHEMAOWNER.headerToProcess);
    
                lv_rowCount := SQL%ROWCOUNT;
                lv_tagRows := lv_tagRows + lv_rowCount;
                lv_EndTime := SYSDATE;
                dbms_output.put_line('Rows Migrated from MS_MSG_TAG Table  ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;


				-- Migrate From Replayable Table 

               INSERT INTO &SCHEMAOWNER.MS_RPLYBL_MSGS (CRTD_AT,LST_UPDT_AT,MSG_STORE_ID,RPLY_COUNT,NXT_RUN_AT,ACTIVE,RPLYNG)
                SELECT RM.CRTD_AT,RM.LST_UPDT_AT,RM.MSG_STORE_ID,RM.RPLY_COUNT,RM.NXT_RUN_AT,RM.ACTIVE,RM.RPLYNG
                FROM &SOURCE_USER.MS_RPLYBL_MSGS RM
                WHERE RM.MSG_STORE_ID IN (SELECT msg_hdr_id FROM &SCHEMAOWNER.headerToProcess);
        
                lv_rowCount := SQL%ROWCOUNT;
                lv_replayRows := lv_replayRows + lv_rowCount;
                lv_EndTime := SYSDATE;
                dbms_output.put_line('Rows migrated from Replable Table  ' || CAST(lv_rowCount AS VARCHAR2) || '.Total time elapsed: ' ||  CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
                
                -- Delete from temporary table.
                DELETE FROM &SCHEMAOWNER.messageHeadersToMigrate WHERE msg_hdr_id IN (SELECT msg_hdr_id FROM &SCHEMAOWNER.headerToProcess);
    
                lv_rowsMigrated := SQL%ROWCOUNT;
    
                COMMIT;

				-- Check if we processed the complete dataset
				IF lv_rowsMigrated < lv_BatchSize THEN
                    EXIT;
                END IF;
            END;
        END LOOP;
     END;
    
	lv_EndTime := SYSDATE;

	
	dbms_output.put_line('----SUMMARY----') ;
	dbms_output.put_line('Start Time: ' || CAST(lv_StartTime as VARCHAR2)) ;
	dbms_output.put_line('Servies Rows Created: ' || CAST(lv_serviceRows AS VARCHAR2)) ;
	dbms_output.put_line('Tag Ref Rows Migrated: ' || CAST(lv_tagRefRows AS VARCHAR2)) ;
	dbms_output.put_line('Total Body Iterations: ' || CAST(lv_bodyIteration AS VARCHAR2)) ;
	dbms_output.put_line('Body Rows Migrated: ' || CAST(lv_bodyRows AS VARCHAR2)) ;
	dbms_output.put_line('Total Header Iterations: ' || CAST(lv_headerIteration AS VARCHAR2)) ;
	dbms_output.put_line('Event Rows Migrated: ' || CAST(lv_eventRows AS VARCHAR2)) ;
	dbms_output.put_line('Replay Rows Migrated: ' || CAST(lv_replayRows AS VARCHAR2)) ;
	dbms_output.put_line('Tag transactional Rows Migrated: ' || CAST(lv_tagRows AS VARCHAR2)) ;
	dbms_output.put_line('End Time: ' || CAST(lv_EndTime as VARCHAR2)) ;
	dbms_output.put_line('Total Time Taken: ' || CAST((lv_StartTime - lv_EndTime)*24*60*60 AS VARCHAR2) || ' secs.') ;
	
END;
