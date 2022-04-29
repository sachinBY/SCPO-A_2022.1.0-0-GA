## Procedure 

1. Login as DBA.
2. Run the scripts in the numbered order(01 to 11) as database task before deploying message store. 
Below is the description of each script - 

| Name | Type | Used By | Description|
|---|---|---|---|
01_create_schema_user | USER Creation Script | Message Store | Creates user |
02_create_tables | Object Creation Script | Message Store | Create tables within schema |
03_create_indexes | Object Creation Script | Message Store | Creates required indexes within schema |
04_sp_ms_get_events | Stored Procedure | Message Store | Used by get Event operation |
05_pre_requisit_to-purge | Global Temporary table Creation Script | Message Store | Creates Temporary Global table. It should be one per database |
06_sp_ms_get_message_by_id | Stored Procedure | Message Store | Used by get message operation |
07_sp_ms_post_events | Stored Procedure | Message Store | Used by post events operation |
08_sp_ms_post_message | Stored Procedure | Message Store | Used by post message operation |
09_sp_prepareToPurge | Stored Procedure | Purge Scripts | Used for marking to be purged records |
10_sp_purgeMessages | Stored Procedure | Purge Scripts | Used for deleting the records |
11_sp_ms_post_bulk_header | Stored Procedure | Message Store | Used by post bulk header operation, adds the header |
12_sp_ms_post_bulk_header_events | Stored Procedure | Message Store | Used by post bulk event operation, adds the event against header |
13_sp_ms_post_bulk_record_header | Stored Procedure | Message Store | Used by record header operation, adds record header against the bulk header |
14_sp_ms_post_bulk_record_header_events | Stored Procedure | Message Store | Used by record event operation, adds record event against record header |
15_grant_dml_new_user.sql | Provide Grants | Grant Scripts | Used for Granting DML and Exec permission and also it has queries to Synonyms for CONNECT_MS_APP user to execute the Proc and tables from CNNECT_MS|


**Note** Recommendation is to update the password in script_01 (01_create_schema_user) and not to change the users and schema name. 

3. Configure message Store app : By default script_01 (01_create_schema_user) creates 2 users, PFB details - 

| User Name | Purpose | 
|---|---|
| CONNECT_MS | This is schema owner user and has DDL privileges over the schema. Should be used by operations and can be distributed to dev teams if required|
| CONNECT_MS_APP | This user has DML privileges over the schema.  <span style="color:red"> ***MS application*** <span>should be configured with this user. | 
