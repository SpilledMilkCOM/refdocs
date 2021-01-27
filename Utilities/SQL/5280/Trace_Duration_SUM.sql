--
-- The table to be selected should be a TRACE table saved from the SQL Profiler.
--

SELECT
		  CONVERT(CHAR(64), TextData)								AS 'sProc Name'
		, COUNT(TextData)											AS 'Calls'
		, SUM(Duration)												AS 'Duration'
FROM (
	SELECT
--			  CONVERT(CHAR(64), TextData)						AS 'TextData'
-- 			, CHARINDEX(' ', CONVERT(CHAR(64), TextData))
-- 			, CHARINDEX(' ', CONVERT(CHAR(64), TextData), CHARINDEX(' ', CONVERT(CHAR(64), TextData)) + 1)
			 SUBSTRING(TextData
						, CHARINDEX(' ', CONVERT(CHAR(64), TextData))
						, CHARINDEX(' ', CONVERT(CHAR(64), TextData), CHARINDEX(' ', CONVERT(CHAR(64), TextData)) + 1)
							- CHARINDEX(' ', CONVERT(CHAR(64), TextData))
						)
			AS 'TextData'
			, Duration
	FROM trace_UTBCALC
	WHERE CONVERT(CHAR(4), TextData) = 'exec'
	) TraceTable

GROUP BY TextData

ORDER BY Duration DESC
--ORDER BY Calls DESC