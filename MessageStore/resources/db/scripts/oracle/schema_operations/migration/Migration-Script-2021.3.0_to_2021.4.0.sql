/*
 * Changes:
 * 1. Schema changes related to MS auto purge 
 * 2. Add the current message store schema version 
 */


/*
* ************** 1. Schema changes related to MS auto purge  ****************
*/
-- Message Store Automated Purge related Schema Changes 
-- Log table to capture the MS purge process details.    
CREATE TABLE MS_PURGE_LOG
(
   PURG_ID        NUMBER (10),
   PURG_STEP_ID   NUMBER (19) GENERATED BY DEFAULT AS IDENTITY (START WITH 1 NOCACHE),
   CREATION_TIME   TIMESTAMP DEFAULT SYSTIMESTAMP,
   START_TIME     TIMESTAMP,
   END_TIME       TIMESTAMP,
   STEP_DESC      VARCHAR2 (255),
   REC_COUNT      NUMBER (10),
   ITERATION      NUMBER (10)
);


-- Sequence to genarate  value for MS_PURGE_LOG.PURG_ID 
CREATE SEQUENCE PURGE_JOB_SEQ START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999; 


-- Indexe to speedup purge performance 
CREATE INDEX PURGE_BDY_LSTUPDT_I ON MS_MSG_BDY(LST_UPDT_AT,ACTIVE);
CREATE INDEX PURGE_HDR_LSTUPDT_I ON MS_MSG_HDR(LST_UPDT_AT,ACTIVE);
CREATE INDEX PURGE_HDR_ACTIVE_I ON MS_MSG_HDR (ACTIVE);
CREATE INDEX PURGE_BDY_ACTIVE_I ON MS_MSG_BDY (ACTIVE);
CREATE INDEX PURGE_TAG_HDR_I ON MS_MSG_TAG (MSG_HDR_ID );

-- Index used for purge data based on CREATION_TIME
CREATE INDEX MS_PURGE_LOG_CT_I ON MS_PURGE_LOG(CREATION_TIME);
-- Index used for purge data in header Body table
CREATE INDEX MSG_HDR_BDY_ID_INDEX ON MS_MSG_HDR (MSG_BDY_ID);


/*
* ************** 2. Add the current message store schema version. ****************
*/
INSERT INTO MS_VER(VER, CRTD_AT) VALUES('2021.4.0', CURRENT_TIMESTAMP);
COMMIT;
