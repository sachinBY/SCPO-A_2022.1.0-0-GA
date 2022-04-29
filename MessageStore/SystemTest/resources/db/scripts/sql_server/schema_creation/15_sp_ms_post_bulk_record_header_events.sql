:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_bulk_record_header_event
(
@now DATETIME,
@bulkHeaderId BIGINT,
@recordHeaderId BIGINT,
@status VARCHAR (64),
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc VARCHAR (1000),
@errorDetailedDesc VARCHAR (2000),
@taskName VARCHAR (255),
@taskId VARCHAR (255),
@recordHeaderEventId BIGINT OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRANSACTION
	
	
	--SELECT BLK_HDR_ID FROM MS_RCRD_HDR WHERE BLK_RCRD_HDR_ID = @recordHeaderId AND BLK_HDR_ID = @bulkHeaderId


	INSERT INTO MS_RCRD_EVNT(RCRD_HDR_ID,BLK_HDR_ID,STATUS,TASK_NAME,TASK_ID,CRTD_AT,ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC) 
	VALUES (@recordHeaderId, @bulkHeaderId, @status, @taskName, @taskId, @now, @errorCategory, @errorCode, @errorDesc, @errorReason, @errorDetailedDesc)

	SET @recordHeaderEventId=SCOPE_IDENTITY()
	
	
	UPDATE
	  MS_RCRD_HDR 
	SET 
	  CRNT_STATUS = @status,
	  LST_TASK = @taskName,   
	  LST_UPDT_AT = @now 
	WHERE 
	  BLK_RCRD_HDR_ID = @recordHeaderId
	  
	COMMIT TRANSACTION
				
END

GO
