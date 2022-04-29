DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.ms_post_bulk_header_events
(
p_headerId NUMBER,
p_status VARCHAR2,
p_now TIMESTAMP,
p_errorCategory VARCHAR2 ,
p_errorReason VARCHAR2 ,
p_errorCode VARCHAR2 ,
p_errorDesc VARCHAR2 ,
p_errorDetailedDesc VARCHAR2 ,
p_totalRecords NUMBER ,
p_processedRecords NUMBER ,
p_sucessRecords NUMBER ,
p_failedRecords NUMBER ,
p_batchId VARCHAR2 ,
p_batchTask VARCHAR2 ,
p_eventId OUT NUMBER

)
AS
 PRAGMA AUTONOMOUS_TRANSACTION;
 
BEGIN

		INSERT INTO MS_BLK_EVNT(BLK_HDR_ID, STATUS, CRTD_AT, BTCH_ID, BTCH_TASK, BTCH_TOT_REC, BTCH_PRC_REC, BTCH_SUC_REC, BTCH_FLD_REC, ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC)
			VALUES(p_headerId, p_status, p_now, p_batchId, p_batchTask, p_totalRecords, p_processedRecords, p_sucessRecords, p_failedRecords,p_errorCategory , p_errorCode, p_errorDesc, p_errorReason, p_errorDetailedDesc) returning BLK_EVNT_ID into p_eventId;

		UPDATE MS_BLK_HDR
			SET
				CRNT_STATUS = p_status,
				LST_UPDT_AT = p_now
			WHERE
				BLK_HDR_ID = p_headerId;

	COMMIT;
				
END;
