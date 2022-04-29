DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.ms_post_messages
(
p_now TIMESTAMP,
p_frmt VARCHAR2,
p_bodyDedupKey VARCHAR2,
p_body BLOB,
p_sts VARCHAR2,
p_headerDedupKey VARCHAR2,
p_dedupServiceKey VARCHAR2,
p_serviceType VARCHAR2,
p_serviceName VARCHAR2,
p_serviceVersion VARCHAR2,
p_serviceInstance VARCHAR2 ,
p_serviceHostName VARCHAR2 ,
p_endPointType VARCHAR2 ,
p_endPointName VARCHAR2 ,
p_modelType VARCHAR2 ,
p_messageCategory VARCHAR2 ,
p_messageType VARCHAR2 ,
p_messageVersion VARCHAR2 ,
p_messageId VARCHAR2 ,
p_messageSender VARCHAR2 ,
p_messageReceivers VARCHAR2 ,
p_docId VARCHAR2 ,
p_docCustId VARCHAR2 ,
p_docTimestamp TIMESTAMP,
p_refSender VARCHAR2,
p_refMessageId VARCHAR2 ,
p_refDocumentId VARCHAR2 ,
p_testMsg NUMBER,
p_errorCategory VARCHAR2,
p_errorReason VARCHAR2,
p_errorCode VARCHAR2 ,
p_errorDesc VARCHAR2 ,
p_errorDetailedDesc VARCHAR2,
p_failWhenDuplicate NUMBER,
p_isReplayable NUMBER,
p_taskId VARCHAR2,
p_taskName VARCHAR2,
p_trackingId VARCHAR2,
p_srcTrackingId VARCHAR2,
p_headerId OUT NUMBER 
)
AS
 v_bodyId NUMBER(19);
 v_svcId NUMBER(5);
 
BEGIN

   BEGIN
    SELECT SRVC_ID INTO v_svcId FROM (SELECT SRVC_ID FROM MS_SRVC WHERE D_DUP_KEY = p_dedupServiceKey) WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found 
        THEN
          v_svcId := null;
  END;
  
  IF v_svcId IS NULL
	THEN
        BEGIN 
            INSERT INTO MS_SRVC (D_DUP_KEY, SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST)
                VALUES
                (p_dedupServiceKey, p_serviceType, p_serviceName,  p_serviceVersion, p_serviceInstance, p_serviceHostName) returning SRVC_ID into v_svcId;
            
            EXCEPTION 
                WHEN DUP_VAL_ON_INDEX
                THEN 
                SELECT SRVC_ID INTO v_svcId FROM (SELECT SRVC_ID FROM MS_SRVC WHERE D_DUP_KEY = p_dedupServiceKey) WHERE rownum = 1;
        END ;
    END IF;
	COMMIT;
    


 SAVEPOINT ms_store;
  BEGIN
    SELECT MSG_BDY_ID INTO v_bodyId FROM (SELECT MSG_BDY_ID FROM MS_MSG_BDY where D_DUP_KEY = p_bodyDedupKey AND ACTIVE = 1) WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found 
        THEN
          v_bodyId := null;
  END;
  
  IF v_bodyId IS NULL
	THEN
		INSERT INTO MS_MSG_BDY(CRTD_AT,LST_UPDT_AT,MSG_FRMT,D_DUP_KEY,MSG_BDY) VALUES(p_now, p_now ,p_frmt, p_bodyDedupKey, p_body) returning MSG_BDY_ID into v_bodyId;
	ELSE
	   UPDATE MS_MSG_BDY SET LST_UPDT_AT = p_now WHERE MSG_BDY_ID=v_bodyId AND ACTIVE=1;
  END IF;
  

  IF 	p_failWhenDuplicate = 0
	THEN
	  BEGIN
		SELECT MSG_HDR_ID INTO p_headerId FROM (SELECT MSG_HDR_ID FROM MS_MSG_HDR WHERE D_DUP_KEY = p_headerDedupKey) WHERE rownum = 1;
		EXCEPTION
		 WHEN no_data_found 
		    THEN
			  p_headerId := null;
	  END;
   END IF;

   IF p_headerId IS NULL
	 THEN
	    INSERT INTO MS_MSG_HDR (MSG_BDY_ID,CRTD_AT,LST_UPDT_AT,CRNT_STATUS,D_DUP_KEY,SRVC_ID,
					END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,MSG_CAT,MSG_TYPE,MSG_VER,MSG_ID,MSG_SNDR,MSG_RCVRS,
					DOC_ID,DOC_CUST_ID,DOC_TMSTMP,REF_MSG_SNDR,REF_MSG_ID,REF_DOC_ID,TST_MSG,TRCKING_ID,SRC_TRCKING_ID)
					VALUES
					(v_bodyId,p_now,p_now,p_sts,p_headerDedupKey,v_svcId,p_endPointType,p_endPointName,p_modelType,p_messageCategory,p_messageType,p_messageVersion,p_messageId,p_messageSender,p_messageReceivers,
					p_docId,p_docCustId,p_docTimestamp,p_refSender,p_refMessageId,p_refDocumentId,p_testMsg,p_trackingId,p_srcTrackingId) returning MSG_HDR_ID into p_headerId;
   END IF;


	INSERT INTO MS_MSG_EVNT(CRTD_AT, MSG_HDR_ID, STATUS, ERR_CAT, ERR_REASON, ERR_CODE, ERR_DESC, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
		VALUES
		(p_now, p_headerId, p_sts, p_errorCategory, p_errorReason, p_errorCode, p_errorDesc, p_errorDetailedDesc, p_taskId, p_taskName);
	COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
	ROLLBACK TO ms_store;
	RAISE;
END;