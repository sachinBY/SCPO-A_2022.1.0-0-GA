## Procedure 

1. Login as DBA.
2. Run the scripts in the numbered order(01 to 11) as database task before deploying message store. 
Below is the description of each script - 

| Name | Type | Used By | Description|
|---|---|---|---|
01_create_login_user | Object Creation Script | Message Store | Creates login user |
02_create_schema | Object Creation Script | Message Store | Creates MS Schema |
03_create_schema_user | Object Creation Script | Message Store | Creates schema user |
04_create_tables | Object Creation Script | Message Store | Create tables within schema |
05_create_indexes | Object Creation Script | Message Store | Creates required indexes within schema |
06_sp_ms_get_events | Stored Procedure | Message Store | Used by get Event operation |
07_sp_ms_get_message_by_id | Stored Procedure | Message Store | Used by get message operation |
08_sp_ms_post_events | Stored Procedure | Message Store | Used by post events operation |
09_sp_ms_post_message | Stored Procedure | Message Store | Used by post message operation |
10_sp_prepareToPurge | Stored Procedure | Purge Scripts | Used for marking to be purged records |
11_sp_purgeMessages | Stored Procedure | Purge Scripts | Used for deleting the records |
12_sp_ms_post_bulk_header | Stored Procedure | Message Store | Used by post bulk header operation, adds the header |
13_sp_ms_post_bulk_header_events | Stored Procedure | Message Store | Used by post bulk event operation, adds the event against header |
14_sp_ms_post_bulk_record_header | Stored Procedure | Message Store | Used by record header operation, adds record header against the bulk header |
15_sp_ms_post_bulk_record_header_events | Stored Procedure | Message Store | Used by record event operation, adds record event against record header |

**Note** Recommendation is to update the password in script_01 (01_create_login_user) and not to change the users and schema name. 

3. Configure message Store app : By default script_01 (01_create_login_user) creates 2 users, PFB details - 

| User Name | Purpose | 
|---|---|
| CONNECT_MS | This is schema owner user and has DDL privileges over the schema. Should be used by operations and can be distributed to dev teams if required |
| CONNECT_MS_APP | This user has DML privileges over the schema. <span style="color:red"> ***MS application*** <span>should be configured with this user. | 


<span style="color:red">  **Note** <span style="color:red">  To run above, Please make sure you enable the script execution in your tooling. 

| Tool Name | How to enable| 
|---|---|
| **SSMS** | Go to the "Query" menu in Top Pinned Bar, and select **SQLCMD** mode . |
| **Azure Data Studio** | A toogle is available on the query editor page in the top right(**Enable SqlCmd**) |
