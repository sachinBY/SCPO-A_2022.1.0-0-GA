DECLARE @purgeId INT
DECLARE @outputSummary VARCHAR(2048)
EXECUTE prepareToPurge @p_retentionDays = 5, @p_batchSize = 5000, @o_purgeId = @purgeId OUTPUT, @o_outputSummary = @outputSummary OUTPUT
PRINT @purgeId
PRINT @outputSummary