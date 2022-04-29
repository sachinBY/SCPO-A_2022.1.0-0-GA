:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_messages
(
@now DATETIME,
@format VARCHAR (64),
@bodyDedupKey VARCHAR (255),
@body VARBINARY (MAX),
@status VARCHAR (255),
@headerDedupKey VARCHAR (255),
@dedupServiceKey VARCHAR (255),
@serviceType VARCHAR (255),
@serviceName VARCHAR (255),
@serviceVersion VARCHAR (255),
@serviceInstance VARCHAR (255),
@serviceHostName VARCHAR (255),
@endPointType VARCHAR (255),
@endPointName VARCHAR (255),
@modelType VARCHAR (255),
@messageCategory VARCHAR (255),
@messageType VARCHAR (255),
@messageVersion VARCHAR (255),
@messageId VARCHAR (255),
@messageSender VARCHAR (255),
@messageReceivers VARCHAR (255),
@docId VARCHAR (255),
@docCustId VARCHAR (255),
@docTimestamp DATETIME,
@refSender VARCHAR (255),
@refMessageId VARCHAR (255),
@refDocumentId VARCHAR (255),
@testMsg TINYINT,
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc VARCHAR (1000),
@errorDetailedDesc NVARCHAR (2000),
@failWhenDuplicate TINYINT,
@isReplayable TINYINT,
@taskId VARCHAR (255),
@taskName VARCHAR (255),
@trackingId VARCHAR (255),
@srcTrackingId VARCHAR (255),
@headerId BIGINT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	-- DECLARE @now DATETIME
	-- SET @now =  GETUTCDATE()

	-- Check Body exsistance before storing
	DECLARE @bodyId BIGINT
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
		select @bodyId=MSG_BDY_ID from MS_MSG_BDY where D_DUP_KEY = @bodyDedupKey AND ACTIVE = 1

		-- Add the body if not found
		IF @bodyId IS NULL
			BEGIN
				INSERT INTO MS_MSG_BDY(CRTD_AT, LST_UPDT_AT, MSG_FRMT,D_DUP_KEY,MSG_BDY) VALUES(@now, @now, @format, @bodyDedupKey, @body)
				SET @bodyId = SCOPE_IDENTITY ()
			END
		ELSE 
			BEGIN
				UPDATE MS_MSG_BDY
				SET LST_UPDT_AT = @now
				WHERE MSG_BDY_ID=@bodyId
				AND ACTIVE=1
			END
			
		IF 	@failWhenDuplicate = 0
			BEGIN
				select @headerId=MSG_HDR_ID from MS_MSG_HDR where D_DUP_KEY = @headerDedupKey
			END
			
		-- Keep duplicates pass through and do not update the body pointer.
		IF @headerId IS NULL
			BEGIN
				INSERT INTO MS_MSG_HDR (MSG_BDY_ID,CRTD_AT,LST_UPDT_AT,CRNT_STATUS,D_DUP_KEY,SRVC_ID,
						END_PNT_TYPE,END_PNT_NAME,MDL_TYPE,MSG_CAT,MSG_TYPE,MSG_VER,MSG_ID,MSG_SNDR,MSG_RCVRS,
						DOC_ID,DOC_CUST_ID,DOC_TMSTMP,REF_MSG_SNDR,REF_MSG_ID,REF_DOC_ID,TST_MSG,TRCKING_ID,SRC_TRCKING_ID)
						VALUES
						(@bodyId,@now,@now,@status,@headerDedupKey,@svcId,@endPointType,@endPointName,@modelType,@messageCategory,@messageType,@messageVersion,@messageId,@messageSender,@messageReceivers,
						@docId,@docCustId,@docTimestamp,@refSender,@refMessageId,@refDocumentId,@testMsg,@trackingId,@srcTrackingId)
				SET @headerId = SCOPE_IDENTITY ()
			END


		INSERT INTO MS_MSG_EVNT(CRTD_AT, MSG_HDR_ID, STATUS, ERR_CAT, ERR_REASON, ERR_CODE, ERR_DESC, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
			VALUES
			(@now, @headerId, @status, @errorCategory, @errorReason, @errorCode, @errorDesc, @errorDetailedDesc, @taskId, @taskName)

	COMMIT TRANSACTION

END
