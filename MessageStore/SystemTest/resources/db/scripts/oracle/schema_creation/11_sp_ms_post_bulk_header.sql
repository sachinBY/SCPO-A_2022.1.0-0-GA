DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.ms_post_bulk_header
(
p_now TIMESTAMP ,
p_status VARCHAR2 ,
p_dedupServiceKey VARCHAR2 ,
p_serviceType VARCHAR2 ,
p_serviceName VARCHAR2 ,
p_serviceVersion VARCHAR2 ,
p_serviceInstance VARCHAR2 ,
p_serviceHostName VARCHAR2 ,
p_errorCategory VARCHAR2 ,
p_errorReason VARCHAR2 ,
p_errorCode VARCHAR2 ,
p_errorDesc VARCHAR2 ,
p_errorDetailedDesc VARCHAR2 ,
p_endPointType VARCHAR2 ,
p_endPointName VARCHAR2 ,
p_modelType VARCHAR2 ,
p_bulkId VARCHAR2 ,
p_bulkType VARCHAR2 , 
p_bulkVersion VARCHAR2 , 
p_bulkSrc VARCHAR2 , 
p_bulkSrcId VARCHAR2 , 
p_bulkLoc VARCHAR2 , 
p_bulkFormat VARCHAR2 , 
p_totalRecords NUMBER ,
p_processedRecords NUMBER ,
p_sucessRecords NUMBER ,
p_failedRecords NUMBER ,
p_batchId VARCHAR2 , 
p_batchTask VARCHAR2 , 
p_bulkHeaderId OUT NUMBER
)
AS
 v_svcId NUMBER(5);
 PRAGMA AUTONOMOUS_TRANSACTION; 
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

	INSERT INTO MS_BLK_HDR (CRTD_AT,LST_UPDT_AT,CRNT_STATUS,SRVC_ID,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,BLK_ID,BLK_TYPE,BLK_VER,BLK_SRC,BLK_LOC,BLK_FORMAT,BLK_SRC_ID)
		VALUES
		(p_now, p_now, p_status, v_svcId, p_endPointType, p_endPointName, p_modelType, p_bulkId, p_bulkType, p_bulkVersion, p_bulkSrc, p_bulkLoc, p_bulkFormat, p_bulkSrcId) returning BLK_HDR_ID into p_bulkHeaderId;

	INSERT INTO MS_BLK_EVNT(BLK_HDR_ID, STATUS, CRTD_AT, BTCH_ID, BTCH_TASK, BTCH_TOT_REC, BTCH_PRC_REC, BTCH_SUC_REC, BTCH_FLD_REC, ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC)
		VALUES
		(p_bulkHeaderId, p_status, p_now, p_batchId, p_batchTask, p_totalRecords, p_processedRecords, p_sucessRecords, p_failedRecords,p_errorCategory , p_errorCode, p_errorDesc, p_errorReason, p_errorDetailedDesc);

	COMMIT;

END;
