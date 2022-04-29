:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_bulk_header_events
(
@headerId BIGINT,
@status VARCHAR (64),
@now DATETIME,
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc VARCHAR (1000),
@errorDetailedDesc VARCHAR (2000),
@totalRecords BIGINT,
@processedRecords BIGINT,
@sucessRecords BIGINT,
@failedRecords BIGINT ,
@batchId VARCHAR (255),
@batchTask VARCHAR (255),
@eventId BIGINT OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION

		INSERT INTO MS_BLK_EVNT(BLK_HDR_ID, STATUS, CRTD_AT, BTCH_ID, BTCH_TASK, BTCH_TOT_REC, BTCH_PRC_REC, BTCH_SUC_REC, BTCH_FLD_REC, ERR_CAT, ERR_CODE, ERR_DESC, ERR_REASON, ERR_DETAIL_DESC)
			VALUES(@headerId, @status, @now, @batchId, @batchTask, @totalRecords, @processedRecords, @sucessRecords, @failedRecords,@errorCategory , @errorCode, @errorDesc, @errorReason, @errorDetailedDesc)

		SET @eventId=SCOPE_IDENTITY()

	
		UPDATE MS_BLK_HDR
			SET
				CRNT_STATUS = @status,
				LST_UPDT_AT = @now
			WHERE
				BLK_HDR_ID = @headerId

	COMMIT TRANSACTION
				
END

GO
