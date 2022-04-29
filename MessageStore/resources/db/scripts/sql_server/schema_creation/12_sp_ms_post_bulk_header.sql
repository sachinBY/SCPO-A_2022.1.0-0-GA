:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_bulk_header
(
@now DATETIME,
@status VARCHAR (255),
@dedupServiceKey VARCHAR (255),
@serviceType VARCHAR (255),
@serviceName VARCHAR (255),
@serviceVersion VARCHAR (255),
@serviceInstance VARCHAR (255),
@serviceHostName VARCHAR (255),
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc NVARCHAR (1000),
@errorDetailedDesc NVARCHAR (2000),
@endPointType VARCHAR (255),
@endPointName VARCHAR (255),
@modelType VARCHAR (255),
@bulkId VARCHAR (255),
@bulkType VARCHAR (255),
@bulkVersion VARCHAR (255),
@bulkSrc VARCHAR (255),
@bulkSrcId VARCHAR (255),
@bulkLoc VARCHAR (255),
@bulkFormat VARCHAR (255),
@totalRecords BIGINT,
@processedRecords BIGINT,
@sucessRecords BIGINT,
@failedRecords BIGINT ,
@batchId VARCHAR (255),
@batchTask VARCHAR (255),
@bulkHeaderId BIGINT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	-- DECLARE @now DATETIME
	-- SET @now =  GETUTCDATE()

	DECLARE @svcId SMALLINT

	-- Broken into two transactions to address JCI-8676 -- 
	BEGIN TRANSACTION
			-- Check for service exsistance
		select @svcId=SRVC_ID FROM MS_SRVC WITH(NOLOCK) WHERE D_DUP_KEY = @dedupServiceKey
		
		-- ************ Needs to be checked **************
		-- Add the service if not found
		IF @svcId IS NULL
			BEGIN TRY
				INSERT INTO MS_SRVC (D_DUP_KEY, SRVC_TYPE, SRVC_NAME, SRVC_VER, SRVC_INST, SRVC_HOST)
				VALUES
				(@dedupServiceKey, @serviceType, @serviceName,  @serviceVersion, @serviceInstance, @serviceHostName)
				SET @svcId = SCOPE_IDENTITY ()
			END TRY
			BEGIN CATCH
				select @svcId=SRVC_ID FROM MS_SRVC WHERE D_DUP_KEY = @dedupServiceKey
			END CATCH
	COMMIT TRANSACTION

	BEGIN TRANSACTION

	INSERT INTO MS_BLK_HDR (CRTD_AT,LST_UPDT_AT,CRNT_STATUS,SRVC_ID,END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,BLK_ID,BLK_TYPE,BLK_VER,BLK_SRC,BLK_LOC,BLK_FORMAT,BLK_SRC_ID)
		VALUES
		(@now, @now, @status, @svcId, @endPointType, @endPointName, @modelType, @bulkId, @bulkType, @bulkVersion, @bulkSrc, @bulkLoc, @bulkFormat, @bulkSrcId)

	SET @bulkHeaderId=SCOPE_IDENTITY()

	INSERT INTO MS_BLK_EVNT(BLK_HDR_ID, STATUS, CRTD_AT, BTCH_ID, BTCH_TASK, BTCH_TOT_REC, BTCH_PRC_REC, BTCH_SUC_REC, BTCH_FLD_REC, ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC)
		VALUES
		(@bulkHeaderId, @status, @now, @batchId, @batchTask, @totalRecords, @processedRecords, @sucessRecords, @failedRecords,@errorCategory , @errorCode, @errorDesc, @errorReason, @errorDetailedDesc)

	COMMIT TRANSACTION

END
