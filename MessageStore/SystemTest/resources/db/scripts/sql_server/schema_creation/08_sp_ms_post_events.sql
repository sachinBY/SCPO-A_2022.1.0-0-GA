:setvar SCHEMANAME CONNECT_MS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).ms_post_events
(
@now DATETIME,
@headerId BIGINT,
@status VARCHAR (64),
@errorCategory VARCHAR(20),
@errorReason VARCHAR(50),
@errorCode VARCHAR (40),
@errorDesc NVARCHAR (1000),
@errorDetailedDesc NVARCHAR (2000),
@isReplayable TINYINT,
@taskId VARCHAR (255),
@taskName VARCHAR (255),
@eventId BIGINT OUTPUT,
@replaybleCount TINYINT OUTPUT,
-- @replayableMsgId SMALLINT OUTPUT,
@nextRunAt DATETIME OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRANSACTION
        INSERT INTO MS_MSG_EVNT(CRTD_AT, MSG_HDR_ID, STATUS, ERR_CAT, ERR_REASON, ERR_CODE, ERR_DESC, ERR_DETAIL_DESC, TASK_ID, TASK_NAME)
            VALUES(@now, @headerId, @status, @errorCategory, @errorReason, @errorCode, @errorDesc, @errorDetailedDesc, @taskId, @taskName)
        SET @eventId=SCOPE_IDENTITY()
    
        UPDATE MS_MSG_HDR
            SET
                CRNT_STATUS = @status,
                LST_UPDT_AT = @now
            WHERE
                MSG_HDR_ID = @headerId

        IF @isReplayable is NULL
            BEGIN
                SELECT @replaybleCount=RPLY_COUNT,@nextRunAt=NXT_RUN_AT FROM MS_RPLYBL_MSGS WHERE MSG_STORE_ID = @headerId
                RETURN
            END
        IF (@isReplayable = 1)
            BEGIN
                UPDATE MS_RPLYBL_MSGS 
                SET 
				NXT_RUN_AT =@now,
                ACTIVE = 1
                WHERE MSG_STORE_ID = @headerId
                IF (@@ROWCOUNT = 0)
                    BEGIN
                        INSERT INTO MS_RPLYBL_MSGS(CRTD_AT,LST_UPDT_AT,MSG_STORE_ID,RPLY_COUNT,NXT_RUN_AT)
                            VALUES
                            (@now,@now,@headerId,1,@now)                        
                    END
            END
        ELSE 
            BEGIN
                UPDATE MS_RPLYBL_MSGS 
                SET 
                ACTIVE = 0
                WHERE MSG_STORE_ID = @headerId
            END
    COMMIT TRANSACTION
                
END
GO
