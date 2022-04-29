## Introduction:

This is a one time execution to move to 2020.1.0 version of Message Store. 

## Pre-requisites: 

Please create the schema by following steps in *schema_creation* folder.

## Procedure:

Run the scripts in the numbered order(01 to 03) as database admin user task for data migration. 

| Name | Type | Description |
|---|---|---|
01_clob_to_blob.sql| Function | This will create function to convert clob to blob object |
02_create_sp_data_migration_messages.sql | Stored Procedure | This stored procedure will facilitate messages data migration |
03_create_sp_data_migration_Bulk.sql | Stored Procedure | This stored procedure will facilitate bulk data migration |
04_execute_messages_proc.sql | Execution Script | Describes the sample command to execute messages stored procedure in step 02 |
05_execute_bulk_proc.sql | Execution Script | Describes the sample command to execute bulk stored procedure in step 03 |
06_sequence_maintenance.md | documented instruction | maintenance of identity column involved into migration script |
07_clean_up | Execution Script | Drops the stored procedure created in step step 01, 02 and 03 |

Before Executing scripts 04_execute_messages_proc.sql and 05_execute_bulk_proc.sql, Need to create Synonyms as steps given in schema_creation/15_grant_dml_new_user.sql line number 67 to 71

**Note** To run these, Please make sure you enable the script execution in your tooling.

| Tool Name | How to enable| 
|---|---|
| **Oracle SQL Developer** | Got to **File -> new **  and execute the scripts|