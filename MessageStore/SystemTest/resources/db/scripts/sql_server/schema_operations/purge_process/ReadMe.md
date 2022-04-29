Run the scripts in the numbered order(01 to 02) as purge task, PFB description for the scripts - 

|Script Name| Description|
|---|---|
01_exec_pre_purge | Executes pre-purge Store Procedure to do marking of records to be deleted |
02_exec_purge | Executes purge Store Procedure to delete the records |


**Note** To run these, Please make sure you enable the script execution in your tooling.

| Tool Name | How to enable| 
|---|---|
| **SSMS** | Go to the "Query" menu in Top Pinned Bar, and select **SQLCMD** mode. |
| **Azure Data Studio** | A toogle is available on the query editor page in the top right(**Enable SqlCmd**). |
