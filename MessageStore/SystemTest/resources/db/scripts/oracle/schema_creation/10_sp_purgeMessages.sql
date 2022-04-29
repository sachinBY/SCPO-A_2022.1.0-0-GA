DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.purgeMessages
(
	p_retentionDays    NUMBER,
	p_batchSize    NUMBER,
	p_purgeId   IN       NUMBER,
	p_purgLogRetentionDays   IN       NUMBER,
	o_outputSummary   OUT       VARCHAR2
)
AS
	v_BatchSize   NUMBER(10);
	v_rowsDeleted NUMBER(10);
	v_StartTime   TIMESTAMP;
	v_EndTime     TIMESTAMP;
	v_totalHeaderRows  NUMBER(10) := 0;
	v_totalBodyRows    NUMBER(10) := 0;
	v_rowCount    NUMBER(10);
	v_eventRows   NUMBER(10) := 0;
	v_headerRows  NUMBER(10) := 0;
	v_bodyRows    NUMBER(10) := 0;
	v_tagRows     NUMBER(10) := 0;
	v_bodyIteration   NUMBER(10) := 0;
	v_headerIteration   NUMBER(10) := 0;
	v_replayRows  NUMBER(10) := 0;
	v_Processed      RAW(1);
	
	v_purgeId NUMBER(10);
	v_stepStartTime TIMESTAMP;
	v_purgLogRetentionDays NUMBER(10);

	Invalid_Retention_Days_specified EXCEPTION;
	PRAGMA AUTONOMOUS_TRANSACTION; 

BEGIN

  IF (p_retentionDays <= 0 OR p_retentionDays IS NULL)
	THEN
	    RAISE Invalid_Retention_Days_specified;
	    RETURN;
	END IF;

	IF (p_batchSize <= 0 OR p_batchSize IS NULL)
	THEN
	    v_BatchSize := 1000;
	ELSE
	    v_BatchSize := p_batchSize;
	END IF;

	IF (p_purgeId IS NOT NULL)
	THEN
	    v_purgeId := p_purgeId;
	ELSE
	    v_purgeId := PURGE_JOB_SEQ.NEXTVAL;
	END IF;	

	IF (p_purgLogRetentionDays <= 0 OR p_purgLogRetentionDays IS NULL)
	THEN
	    v_purgLogRetentionDays := 360;
	ELSE
	    v_purgLogRetentionDays := p_purgLogRetentionDays;
	END IF;

	v_StartTime := SYSTIMESTAMP;
	DBMS_OUTPUT.PUT_LINE( '---------------------');
	DBMS_OUTPUT.PUT_LINE( '----START SUMMARY----');
	DBMS_OUTPUT.PUT_LINE( 'Start Time ' || TO_CHAR(v_StartTime));

	DELETE FROM messageHeaderToDelete;
	INSERT INTO messageHeaderToDelete SELECT MSG_HDR_ID FROM MS_MSG_HDR WHERE ACTIVE = 0;
    COMMIT;

BEGIN 
	WHILE 1 = 1
	LOOP

		v_stepStartTime := SYSTIMESTAMP;
		v_headerIteration := v_headerIteration + 1;
		
		DBMS_OUTPUT.PUT_LINE ( 'Iteration: ' || TO_CHAR(v_headerIteration) || ' Time Taken till now : ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));	
		INSERT INTO headerToProcess SELECT MSG_HDR_ID FROM messageHeaderToDelete WHERE rownum <= v_BatchSize;
		v_rowCount := SQL%ROWCOUNT;

		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - HEDER KEY DELETE', v_rowCount);

-- Replayable Table 
		v_stepStartTime := SYSTIMESTAMP;
		DELETE FROM MS_RPLYBL_MSGS WHERE MSG_STORE_ID IN (SELECT msg_hdr_id FROM headerToProcess);
		v_rowCount := SQL%ROWCOUNT;
		v_replayRows := v_replayRows + v_rowCount;
			
		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - PURGE MS_RPLYBL_MSGS', v_rowCount);

-- Delete From EVENTS
        v_stepStartTime := SYSTIMESTAMP;
		DELETE FROM MS_MSG_EVNT WHERE msg_hdr_id IN (SELECT msg_hdr_id FROM headerToProcess);
		v_rowCount := SQL%ROWCOUNT;
		v_eventRows := v_eventRows + v_rowCount;
		
		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - PURGE MS_MSG_EVNT', v_rowCount);

-- Deelte from Tag  

		v_stepStartTime := SYSTIMESTAMP;		
		DELETE FROM MS_MSG_TAG WHERE MSG_HDR_ID IN (SELECT msg_hdr_id FROM headerToProcess);
		v_rowCount := SQL%ROWCOUNT;
		v_tagRows := v_tagRows + v_rowCount;
            
		DBMS_OUTPUT.PUT_LINE ( 'Rows deleted from Tag Table ...' || TO_CHAR(v_rowCount) || ' ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));
		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - PURGE MS_MSG_TAG', v_rowCount);

-- Delete From Header 
		v_stepStartTime := SYSTIMESTAMP;		
		DELETE FROM MS_MSG_HDR WHERE msg_hdr_id IN (SELECT msg_hdr_id FROM headerToProcess);
		v_rowCount := SQL%ROWCOUNT;
		v_headerRows := v_headerRows + v_rowCount;
			
		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - PURGE MS_MSG_HDR', v_rowCount);

-- Temprary table.
		v_stepStartTime := SYSTIMESTAMP;
		DELETE FROM messageHeaderToDelete WHERE msg_hdr_id IN (SELECT msg_hdr_id FROM headerToProcess);
		v_rowsDeleted := SQL%ROWCOUNT;
		DELETE FROM headerToProcess;
            
		INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - DELETE FROM messageHeaderToDelete', v_rowsDeleted);
		
		COMMIT;

-- Successed the complete dataset
		IF v_rowsDeleted < v_BatchSize 
		  THEN 
		    EXIT;
		END IF;
	END LOOP;
END;

BEGIN
    WHILE 1 = 1
		LOOP 
			v_stepStartTime := SYSTIMESTAMP;
			v_bodyIteration := v_bodyIteration + 1;
			DBMS_OUTPUT.PUT_LINE (  'Iteration: ' || TO_CHAR(v_bodyIteration) || ', Time Taken till now : ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

			DELETE FROM MS_MSG_BDY WHERE MSG_BDY_ID IN (SELECT MSG_BDY_ID FROM MS_MSG_BDY WHERE ACTIVE = 0 and ROWNUM <= p_batchSize);
			v_rowCount := SQL%ROWCOUNT;

			v_bodyRows := v_bodyRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Deleted...' || TO_CHAR(v_rowCount) || ' body keys, Time Taken till now: ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));
			INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'STEP - MS_MSG_BDY PURGE', v_rowCount);

			IF (v_rowCount < p_batchSize OR v_rowCount = 0 )
			THEN
				COMMIT;
				EXIT;
			END IF;
			
		COMMIT;
		END LOOP;
END;

-- Purge MS_PURGE_LOG table 
    v_stepStartTime := SYSTIMESTAMP;
    DELETE  FROM MS_PURGE_LOG WHERE CREATION_TIME  < (SYSDATE - p_purgLogRetentionDays);
    v_rowCount := SQL%ROWCOUNT;

    v_EndTime := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE ( '----SUMMARY----');
    DBMS_OUTPUT.PUT_LINE ( 'Start Time: ' || TO_CHAR(v_StartTime));
    DBMS_OUTPUT.PUT_LINE ( 'Total Body Iterations: ' || TO_CHAR(v_bodyIteration));
    DBMS_OUTPUT.PUT_LINE ( 'Total Header Iterations: ' || TO_CHAR(v_headerIteration));
    DBMS_OUTPUT.PUT_LINE ( 'Header Rows Deleted: ' || TO_CHAR(v_headerRows));
    DBMS_OUTPUT.PUT_LINE ( 'Body Rows Deleted: ' || TO_CHAR(v_bodyRows));
    DBMS_OUTPUT.PUT_LINE ( 'Event Rows Deleted: ' || TO_CHAR(v_eventRows));
    DBMS_OUTPUT.PUT_LINE ( 'Replay Rows Deleted: ' || TO_CHAR(v_replayRows));
    DBMS_OUTPUT.PUT_LINE ( 'Tag Rows Deleted: ' || TO_CHAR(v_tagRows));
    DBMS_OUTPUT.PUT_LINE ( 'End Time : ' || TO_CHAR(v_EndTime));
    DBMS_OUTPUT.PUT_LINE ( 'Total Time Taken : ' || TO_CHAR((v_EndTime - v_StartTime)));
   
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS TABLES');
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT,ITERATION) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS_MSG_HDR', v_headerRows,v_headerIteration);
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT,ITERATION) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS_MSG_BDY', v_bodyRows,v_bodyIteration);
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS_MSG_EVNT', v_eventRows);
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS_RPLYBL_MSGS', v_replayRows);
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_StartTime, v_EndTime,'SUMMARY - PURGE MS_MSG_TAG', v_tagRows);
    INSERT INTO MS_PURGE_LOG (PURG_ID, START_TIME, END_TIME, STEP_DESC, REC_COUNT) VALUES (v_purgeId,v_stepStartTime, SYSTIMESTAMP,'SUMMARY - PURGE PURGE_LOG', v_rowCount);
    COMMIT;
 
    o_outputSummary := 'SUMMARY - PURGE MS TABLES  PurgeId - ' || v_purgeId ||' , Start Time - ' || v_StartTime || ' , EndTime - ' || v_EndTime || ' , PURGE MS_MSG_HDR - ' || v_headerRows ||  ' , PURGE MS_MSG_BDY - ' || v_bodyRows ||  ' , PURGE MS_MSG_EVNT - ' || v_eventRows ||  ' , PURGE MS_RPLYBL_MSGS - ' || v_replayRows ||  ' , PURGE MS_MSG_TAG - ' || v_tagRows ||  ' , PURGE PURGE_LOG - ' || v_rowCount ;
    DBMS_OUTPUT.PUT_LINE (  'o_outputSummary - ' || o_outputSummary);
    	

   
END;
/
