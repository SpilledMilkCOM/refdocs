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
===========================================================================*/

DECLARE @jobCount		AS INT
DECLARE @jobName 		AS char(8)
DECLARE @columnTitle	AS char(11)
DECLARE @secondsPerDay	AS FLOAT

DECLARE @mm_dd_yyyy		AS INT
SET 	@mm_dd_yyyy		= 101
DECLARE @HH_MM_SS_mmm	AS INT
SET 	@HH_MM_SS_mmm	= 14


SET @jobName		= 'UTBCALC'
SET @columnTitle	= '*** Seconds'
SET @secondsPerDay	= 86400.0


SELECT 	
	  CONVERT(CHAR(12), hst_strt)										AS 'Hist. From'
	, CONVERT(CHAR(12), hst_end)										AS 'Hist. To'
	, SPACE(5) + CONVERT(CHAR(5), DATEDIFF(dd, hst_strt, hst_end)) 		AS 'Days of Hist.'
FROM
	(SELECT
		  MIN(strt_dt)	AS 'hst_strt'
		, MAX(end_dt)	AS 'hst_end'
	FROM
		utl21t_jobrunhstry with (nolock)
	) hst_days


select 	  utl21t_avg.job
	, CONVERT(VARCHAR(11), SPACE(11 - LEN(CONVERT(VARCHAR(11), utl21t_avg.seconds))) + CONVERT(VARCHAR(11), utl21t_avg.seconds))
	as 'AVG-Seconds'
	, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(datetime, utl21t_avg.seconds / @secondsPerDay), 14), 8)
	as 'AVG-HH:MM:SS'
	, CONVERT(VARCHAR(11), SPACE(11 - LEN(CONVERT(VARCHAR(11), utl21t_max.seconds))) + CONVERT(VARCHAR(11), utl21t_max.seconds))
	as 'MAX-Seconds'
	, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(datetime, utl21t_max.seconds / @secondsPerDay), 14), 8)
	as 'MAX-HH:MM:SS'
	, CONVERT(VARCHAR(11), SPACE(11 - LEN(CONVERT(VARCHAR(11), utl21t_min.seconds))) + CONVERT(VARCHAR(11), utl21t_min.seconds))
	as 'MIN-Seconds'
	, '  ' + LEFT(CONVERT(VARCHAR(13), CONVERT(datetime, utl21t_min.seconds / @secondsPerDay), 14), 8)
	as 'MIN-HH:MM:SS'
	, CONVERT(VARCHAR(11), SPACE(11 - LEN(CONVERT(VARCHAR(11), utl21t_avg.job_cnt))) + CONVERT(VARCHAR(11), utl21t_avg.job_cnt))
	as 'Point(s)'
FROM
	(select    	job
			, COUNT(job) as 'job_cnt'
			, AVG(datediff(ss, strt_dt, end_dt)) as 'seconds'
	from		utl21t_jobrunhstry with (nolock)
/*--*/--	where		job LIKE @jobName			-- Comment out this WHERE to get stats for all jobs
	GROUP BY	job
	) utl21t_avg
INNER JOIN 
	(select    	job
			, MAX(datediff(ss, strt_dt, end_dt)) as 'seconds'
	from		utl21t_jobrunhstry with (nolock)
/*--*/--	where		job LIKE @jobName			-- Comment out this WHERE to get stats for all jobs
	GROUP BY	job
	) utl21t_max
	ON utl21t_avg.job = utl21t_max.job
INNER JOIN 
	(select    	job
			, MIN(datediff(ss, strt_dt, end_dt)) as 'seconds'
	from		utl21t_jobrunhstry with (nolock)
/*--*/--	where		job LIKE @jobName			-- Comment out this WHERE to get stats for all jobs
	GROUP BY	job
	) utl21t_min
	ON utl21t_avg.job = utl21t_min.job
WHERE utl21t_avg.job_cnt > 20
--ORDER BY utl21t_avg.job
ORDER BY utl21t_avg.seconds DESC

SET @jobCount = (select count(job) from utl21t_jobrunhstry with (nolock) where job = @jobName)
PRINT '================================================================================================================'
PRINT ''
PRINT 'History for batch: ' + @jobName + '  (data points = ' + CONVERT(VARCHAR(32), @jobCount) + ')'
PRINT ''

select
	  CONVERT(VARCHAR(13), btch_run_dt, @mm_dd_yyyy)		AS 'BatchRunDate'
	, CONVERT(VARCHAR(13), strt_dt, @mm_dd_yyyy)
	+ ' '
	+ CONVERT(VARCHAR(13), strt_dt, @HH_MM_SS_mmm)			AS '  StartDate'
	, CONVERT(VARCHAR(13), end_dt, @mm_dd_yyyy)
	+ ' '
	+ CONVERT(VARCHAR(13), end_dt, @HH_MM_SS_mmm)			AS '  EndDate'
	, CONVERT(VARCHAR(8), DATEDIFF(ss, strt_dt, end_dt)) 	AS 'Seconds'
	, LEFT(CONVERT(VARCHAR(13), CONVERT(datetime, datediff(ss, strt_dt, end_dt) / @secondsPerDay), 14), 8)
	AS 'HH:MM:SS'
	, CONVERT(VARCHAR(4), datepart(day, btch_run_dt))		AS 'Day'
--	, btch_run_dt
--	, lst_updt_tmestmp
from
	utl21t_jobrunhstry with (nolock)
where
	job = @jobName
ORDER BY datediff(ss, strt_dt, end_dt) DESC --utl21t_jobrunhstry.btch_run_dt