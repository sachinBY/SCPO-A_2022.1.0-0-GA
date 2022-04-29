## Introduction:

This is a one time execution to move the data to 2021.1.0 version of Message Store. 

### Prerequisite: 

Please run this in conjunction with databsae.md, which details out the schema you are migrating from and provides centralized steps. 

## Procedure:

### step 01

Run the scripts in the numbered order(01 to 05) as database task for data migration. 

| Name | Type | Description |
|---|---|---|
01_dm_messages.sql | Stored Procedure | Creates stored procedure to facilitate messages table data migration |
02_dm_bulk.sql | Stored Procedure | Creates stored procedure to facilitate bulk tables data migration |
03_exec_migration | Execution Script | Describes the sample command to execute stored procedure in step 01 |
04_clean_up | Execution Script | Drops the stored procedure created in step 01 |

### step 02

1. Once data migration is complete verify the number of records in the new schema. 
2. delete the old schema post customer data retention days.

<span style="color:red"> ***If you are looking to migrate bulk data then please take help from [here](https://confluence.jda.com/pages/viewpage.action?pageId=357958531).***  </span>

**Note** To run these, Please make sure you enable the script execution in your tooling.

| Tool Name | How to enable| 
|---|---|
| **SSMS** | Go to the "Query" menu in Top Pinned Bar, and select **SQLCMD** mode. |
| **Azure Data Studio** | A toogle is available on the query editor page in the top right(**Enable SqlCmd**). |

