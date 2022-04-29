DECLARE @purge_outputSummary VARCHAR(2048)
-- p_purgeId value will get it from output of prepare purge
EXECUTE purgeMessages @p_retentionDays = 5, @p_batchSize = 5000, @p_purgeId = 1, @p_purgLogRetentionDays =180, @o_outputSummary = @purge_outputSummary OUTPUT
PRINT @purge_outputSummary