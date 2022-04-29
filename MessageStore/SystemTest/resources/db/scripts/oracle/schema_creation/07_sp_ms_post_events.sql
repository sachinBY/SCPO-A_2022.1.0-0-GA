DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.ms_post_events
(
p_now TIMESTAMP,
p_headerId NUMBER,
p_status VARCHAR2 ,
p_errorCategory VARCHAR2,
p_errorReason VARCHAR2,
p_errorCode VARCHAR2 ,
p_errorDesc NVARCHAR2,
p_errorDetailedDesc NVARCHAR2,
p_isReplayable NUMBER,
p_taskId VARCHAR2,
p_taskName VARCHAR2,
p_eventId OUT NUMBER,
p_replaybleCount OUT NUMBER,
p_nextRunAt OUT TIMESTAMP
)
AS
BEGIN
 SAVEPOINT evnt_store;
		INSERT INTO MS_MSG_EVNT(CRTD_AT, MSG_HDR_ID, STATUS, ERR_CAT, ERR_REASON, ERR_CODE, ERR_DESC, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
			VALUES(p_now, p_headerId, p_status, p_errorCategory, p_errorReason, p_errorCode, p_errorDesc, p_errorDetailedDesc, p_taskId, p_taskName) returning MSG_EVNT_ID into p_eventId;
	
		UPDATE MS_MSG_HDR
			SET
				CRNT_STATUS = p_status,
				LST_UPDT_AT = p_now
			WHERE
				MSG_HDR_ID = p_headerId;


		IF p_isReplayable is NULL
		    THEN
              BEGIN
				SELECT RPLY_COUNT,NXT_RUN_AT INTO p_replaybleCount, p_nextRunAt FROM MS_RPLYBL_MSGS WHERE MSG_STORE_ID = p_headerId;
					EXCEPTION
						WHEN no_data_found 
						THEN
						  p_replaybleCount := null;
						  p_nextRunAt := null;
              END;
			RETURN;
	    END IF;

		IF (p_isReplayable = 1)
			THEN
				UPDATE MS_RPLYBL_MSGS SET NXT_RUN_AT = p_now, ACTIVE = 1 WHERE MSG_STORE_ID = p_headerId;
				IF (SQL%ROWCOUNT = 0)
					THEN
						INSERT INTO MS_RPLYBL_MSGS(CRTD_AT,LST_UPDT_AT,MSG_STORE_ID,NXT_RUN_AT) VALUES (p_now,p_now,p_headerId,p_now);						
				END IF;
		ELSE 
			UPDATE MS_RPLYBL_MSGS SET ACTIVE = 0 WHERE MSG_STORE_ID = p_headerId;

		END IF;
COMMIT;
	EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO evnt_store;
      RAISE;	
END;