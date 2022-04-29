:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_bulk_record_header
(
@now DATETIME,
@bulkHeaderId BIGINT,
@status VARCHAR (64),
@recordId VARCHAR (255),
@seqNo BIGINT,
@recordHeaderBody VARBINARY(MAX),
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc VARCHAR (1000),
@errorDetailedDesc VARCHAR (2000),
@taskName VARCHAR (255),
@taskId VARCHAR (255),
@recordHeaderId BIGINT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRANSACTION
	
	
	-- SELECT BLK_HDR_ID FROM MS_BLK_HDR WHERE BLK_HDR_ID = @bulkHeaderId


	INSERT INTO MS_RCRD_HDR(BLK_HDR_ID,CRTD_AT,LST_UPDT_AT,CRNT_STATUS,LST_TASK,RCRD_ID,SEQ_NO,RCRD_HDR_BODY) 
		VALUES (@bulkHeaderId,@now,@now,@status,@taskName,@recordId,@seqNo,@recordHeaderBody)
		
	SET @recordHeaderId=SCOPE_IDENTITY()

	
	INSERT INTO MS_RCRD_EVNT(RCRD_HDR_ID,BLK_HDR_ID, STATUS,TASK_NAME,TASK_ID,CRTD_AT,ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC) 
	VALUES (@recordHeaderId, @bulkHeaderId, @status, @taskName, @taskId, @now, @errorCategory, @errorCode, @errorDesc, @errorReason, @errorDetailedDesc)

	COMMIT TRANSACTION
				
END

GO
