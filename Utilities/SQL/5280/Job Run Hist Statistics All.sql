/*===========================================================================
AUTHOR:		Parker Smart
CREATED:	06/01/2004
PURPOSE:	A utility script that will display Job Run Statistics.

USAGE:		Since this is not a stored procedure (yet) you may want to
		set some options by hand.  See below.

REV.HIST:
10/04/2004	P.Smart		Reworked the formatting.
						o Right justify the seconds
						o Used the date conversion and LEFT to display HH:MM:SS.
						Added "Point(s)" (COUNT) to the output.
08/30/2005	P.Smart		Added conversion to MONEY to get commas in the numbers (ex:  1,234,567)
						Added CURSOR to display ALL the statistics for each job.
						Added MEDIAN() column
===========================================================================*/

SET NOCOUNT ON

DECLARE @jobCount		AS INT
DECLARE @jobName 		AS char(8)

DECLARE @secondsPerDay	AS FLOAT
SET 	@secondsPerDay	= 86400.0

DECLARE @mm_dd_yyyy		AS INT
SET 	@mm_dd_yyyy		= 101
DECLARE @HH_MM_SS_mmm	AS INT
SET 	@HH_MM_SS_mmm	= 14

DECLARE @get_date		AS DATETIME
SET		@get_date		= getdate()

PRINT '                         ---=== Historical Job Statistics ===---'
PRINT ''
PRINT 'Script Date: ' + CONVERT(VARCHAR(13), @get_date, @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), @get_date, @HH_MM_SS_mmm)
PRINT ''
PRINT ''
--EXEC sp_server_info

SELECT 	
	  CONVERT(CHAR(12), hst_strt)										AS 'Hist. From'
	, CONVERT(CHAR(12), hst_end)										AS 'Hist. To'
	, SPACE(5) + CONVERT(CHAR(5), DATEDIFF(dd, hst_strt, hst_end)) 		AS 'Days of Hist.'
	, SPACE(5) + CONVERT(CHAR(5), points) 		AS 'Points of Hist.'
FROM
	(SELECT
		  MIN(strt_dt)	AS 'hst_strt'
		, MAX(end_dt)	AS 'hst_end'
		, COUNT(*)		AS 'points'
	FROM
		utl21t_jobrunhstry WITH (NOLOCK)
	) hst_days

--======================================================================================================

SELECT
		  utl21t_avg.job
		, SPACE(3) + CONVERT(VARCHAR(8), SPACE(11 - LEN(CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_avg.seconds), 1))) + CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_avg.seconds), 1))
		AS 'AVG-Seconds'
		, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(DATETIME, utl21t_avg.seconds / @secondsPerDay), 14), 8)
		AS 'AVG-HH:MM:SS'
		, SPACE(3) + CONVERT(VARCHAR(8), SPACE(11 - LEN(CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_max.seconds), 1))) + CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_max.seconds), 1))
		AS 'MAX-Seconds'
		, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(DATETIME, utl21t_max.seconds / @secondsPerDay), 14), 8)
		AS 'MAX-HH:MM:SS'
		, SPACE(3) + CONVERT(VARCHAR(8), SPACE(11 - LEN(CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_min.seconds), 1))) + CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_min.seconds), 1))
		AS 'MIN-Seconds'
		, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(DATETIME, utl21t_min.seconds / @secondsPerDay), 14), 8)
		AS 'MIN-HH:MM:SS'
		, SPACE(3) + CONVERT(VARCHAR(8), SPACE(11 - LEN(CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_avg.job_cnt), 1))) + CONVERT(VARCHAR(11), CONVERT(MONEY, utl21t_avg.job_cnt), 1))
		AS 'Point(s)'
		, CONVERT(VARCHAR(11), UTL21.strt_dt, 101)
		AS 'MAX-Date'
FROM
	(SELECT    	job
			, COUNT(job)							AS 'job_cnt'
			, AVG(DATEDIFF(ss, strt_dt, end_dt))	AS 'seconds'
	FROM		utl21t_jobrunhstry WITH (NOLOCK)
	GROUP BY	job
	) utl21t_avg

INNER JOIN 
	(SELECT    	job
			, MAX(DATEDIFF(ss, strt_dt, end_dt))	AS 'seconds'
	FROM		utl21t_jobrunhstry WITH (NOLOCK)
	GROUP BY	job
	) utl21t_max
	ON utl21t_max.job = utl21t_avg.job

INNER JOIN 
	(SELECT    	job
			, MIN(datediff(ss, strt_dt, end_dt))	AS 'seconds'
	FROM		utl21t_jobrunhstry WITH (NOLOCK)
	GROUP BY	job
	) utl21t_min
	ON utl21t_min.job = utl21t_avg.job

-- INNER JOIN 
-- 	(SELECT    	job
-- 			, MEDIAN(datediff(ss, strt_dt, end_dt))	AS 'seconds'
-- 	FROM		utl21t_jobrunhstry WITH (NOLOCK)
-- 	GROUP BY	job
-- 	) utl21t_med
-- 	ON utl21t_med.job = utl21t_avg.job

LEFT OUTER JOIN
	utl21t_jobrunhstry 	UTL21		(NOLOCK)
	ON UTL21.job = utl21t_max.job
	AND DATEDIFF(ss, UTL21.strt_dt, UTL21.end_dt) = utl21t_max.seconds

--WHERE utl21t_avg.job_cnt > 20
--ORDER BY utl21t_avg.job
ORDER BY utl21t_avg.seconds DESC

--======================================================================================================

DECLARE theCursor CURSOR FOR
SELECT DISTINCT job
FROM utl21t_jobrunhstry (NOLOCK)
ORDER BY job

OPEN theCursor

FETCH NEXT FROM theCursor INTO @jobName

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @jobCount = (select count(job) from utl21t_jobrunhstry where job = @jobName)
	PRINT '================================================================================================================'
	PRINT ''
	PRINT 'History for batch: ' + @jobName + '  (data points = ' + CONVERT(VARCHAR(32), @jobCount) + ')'
	PRINT ''
	
	SELECT
			  CONVERT(VARCHAR(13), btch_run_dt, @mm_dd_yyyy)		AS 'BatchRunDate'
			, CONVERT(VARCHAR(13), strt_dt, @mm_dd_yyyy)
			+ ' '
			+ CONVERT(VARCHAR(13), strt_dt, @HH_MM_SS_mmm)			AS '  StartDate'
			, CONVERT(VARCHAR(13), end_dt, @mm_dd_yyyy)
			+ ' '
			+ CONVERT(VARCHAR(13), end_dt, @HH_MM_SS_mmm)			AS '  EndDate'
			, CONVERT(VARCHAR(8), DATEDIFF(ss, strt_dt, end_dt)) 	AS 'Seconds'
			, LEFT(CONVERT(VARCHAR(13), CONVERT(DATETIME, datediff(ss, strt_dt, end_dt) / @secondsPerDay), 14), 8)
			AS 'HH:MM:SS'
			, CONVERT(VARCHAR(4), datepart(day, btch_run_dt))		AS 'Day'
		--	, btch_run_dt
		--	, lst_updt_tmestmp
	FROM
		utl21t_jobrunhstry WITH (NOLOCK)
	WHERE
		job = @jobName
	ORDER BY datediff(ss, strt_dt, end_dt) DESC --utl21t_jobrunhstry.btch_run_dt

	FETCH NEXT FROM theCursor INTO @jobName
END

CLOSE theCursor
DEALLOCATE theCursor