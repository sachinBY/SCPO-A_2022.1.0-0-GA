## Introduction:

This is a one time execution to move to 2021.4.0 version of Message Store. 

## Procedure:

Run the script as database admin user task for data migration. 

| Name | Type | Description |
|---|---|---|
exec_migration.sql | Execution Script | add two new nullable column(TRCKING_ID,SRC_TRCKING_ID) to MS_MSG_HDR tabel|
09_sp_ms_post_message.sql | Execution Script | Rerun the procedure from location resources\db\scripts\sql_server\schema_creation |

**Note** To run these, Please make sure you enable the script execution in your tooling.

| Tool Name | How to enable| 
|---|---|
| **SSMS** | Go to the "Query" menu in Top Pinned Bar, and select **SQLCMD** mode. |
| **Azure Data Studio** | A toogle is available on the query editor page in the top right(**Enable SqlCmd**). |