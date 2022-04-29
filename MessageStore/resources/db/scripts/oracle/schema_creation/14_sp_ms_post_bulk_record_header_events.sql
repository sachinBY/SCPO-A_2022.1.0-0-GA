DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.ms_post_bulk_record_header_event
(
p_now TIMESTAMP ,
p_bulkHeaderId NUMBER ,
p_recordHeaderId NUMBER ,
p_status VARCHAR2 ,
p_errorCategory VARCHAR2 ,
p_errorReason VARCHAR2 ,
p_errorCode VARCHAR2 ,
p_errorDesc VARCHAR2 ,
p_errorDetailedDesc VARCHAR2 ,
p_taskName VARCHAR2 ,
p_taskId VARCHAR2 ,
p_recordHeaderEventId OUT NUMBER

)
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN


	INSERT INTO MS_RCRD_EVNT(RCRD_HDR_ID,BLK_HDR_ID,STATUS,TASK_NAME,TASK_ID,CRTD_AT,ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC) 
	VALUES (p_recordHeaderId, p_bulkHeaderId, p_status, p_taskName, p_taskId, p_now, p_errorCategory, p_errorCode, p_errorDesc, p_errorReason, p_errorDetailedDesc)
	returning BLK_RCRD_EVNT_ID into p_recordHeaderEventId;
	
	UPDATE
	  MS_RCRD_HDR 
	SET 
	  CRNT_STATUS = p_status,
	  LST_TASK = p_taskName,   
	  LST_UPDT_AT = p_now 
	WHERE 
	  BLK_RCRD_HDR_ID = p_recordHeaderId;
	  
	COMMIT;
				
END;
