## Procedure 

1. Login as DBA.
2. Execute ***01_Rollback_ms_db.sql***, This will delete all the objects created in the Create Script. 
3. Execute ***02_Rollback_master.sql***, This will delete the login users created for MS Application.

<span style="color:red">  **Note** <span style="color:red">  To run above, Please make sure you enable the script execution in your tooling. 

| Tool Name | How to enable| 
|---|---|
| **SSMS** | Go to the "Query" menu in Top Pinned Bar, and select **SQLCMD** mode . |
| **Azure Data Studio** | A toogle is available on the query editor page in the top right(**Enable SqlCmd**) |
