
DEFINE SCHEMAOWNER = 'CONNECT_MS.';
-- Drop tables
DROP TABLE &SCHEMAOWNER.MS_MSG_TAG;
DROP TABLE &SCHEMAOWNER.MS_TAG;
DROP TABLE &SCHEMAOWNER.MS_RPLYBL_MSGS;

DROP TABLE &SCHEMAOWNER.MS_MSG_EVNT;
DROP TABLE &SCHEMAOWNER.MS_MSG_HDR;
DROP TABLE &SCHEMAOWNER.MS_MSG_BDY;
DROP TABLE &SCHEMAOWNER.MS_SRVC;

DROP TABLE &SCHEMAOWNER.MS_RCRD_EVNT;
DROP TABLE &SCHEMAOWNER.MS_RCRD_HDR;
DROP TABLE &SCHEMAOWNER.MS_BLK_EVNT;
DROP TABLE &SCHEMAOWNER.MS_BLK_HDR;
DROP TABLE &SCHEMAOWNER.MS_VER;
DROP TABLE &SCHEMAOWNER.MS_BLK_INGSTN_EVNT;
DROP TABLE &SCHEMAOWNER.MS_BLK_INGSTN;
DROP TABLE &SCHEMAOWNER.MS_INGSTN_RCRD;
DROP TABLE &SCHEMAOWNER.MS_USER_DATA;
DROP TABLE &SCHEMAOWNER.MS_PURGE_LOG;

-- Drop Sequence
DROP SEQUENCE &SCHEMAOWNER.PURGE_JOB_SEQ; 

-- Drop indexes
DROP INDEX &SCHEMAOWNER.MSG_TAG_TAGID_I ;

-- Drop Stored Procedures 

DROP PROCEDURE &SCHEMAOWNER.ms_get_events;
DROP PROCEDURE &SCHEMAOWNER.ms_get_message_by_id;
DROP PROCEDURE &SCHEMAOWNER.ms_post_events;
DROP PROCEDURE &SCHEMAOWNER.ms_post_messages;
DROP PROCEDURE &SCHEMAOWNER.purgeMessages;
DROP PROCEDURE &SCHEMAOWNER.prepareToPurge;
DROP PROCEDURE &SCHEMAOWNER.ms_post_bulk_header;
DROP PROCEDURE &SCHEMAOWNER.ms_post_bulk_header_events;
DROP PROCEDURE &SCHEMAOWNER.ms_post_bulk_record_header;
DROP PROCEDURE &SCHEMAOWNER.ms_post_bulk_record_header_event;

-- Drop global temporary table
TRUNCATE TABLE &SCHEMAOWNER.messageHeaderToDelete;
DROP TABLE &SCHEMAOWNER.messageHeaderToDelete;

TRUNCATE TABLE &SCHEMAOWNER.headerToProcess;
DROP TABLE &SCHEMAOWNER.headerToProcess