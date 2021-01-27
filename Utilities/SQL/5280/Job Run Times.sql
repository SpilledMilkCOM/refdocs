/*===========================================================================
AUTHOR:		Parker Smart
CREATED:	10/10/2004
PURPOSE:	A utility script that will display Job Run Times.

USAGE:		Since this is not a stored procedure (yet) you may want to set the job name.  See below.

NOTE:		CHANGE OUTPUT TO "TEXT"  (ctrl-T will change your ouput to text)

Columns:
	JOB			- Name of the job
	err_indc	- Error indicator (0 if no errors)
	strt_dt		- Time job started (if a tilde ~ prepends the time then the time is the following day/morning the batch started)
	end_dt		- Time job ended
				* The date is eliminated from strt_dt and end_dt to save report real estate.
	Delay Next	- The difference between the previous job's end_dt and the current job's strt_dt (legend explains the symbols)
	Started		- Full Date and Time the job was started.

Date format:	DDdHH:MM:SS.sss
	DD - days				(sometimes test batch runs can span days - not something you want to see in production though)
	HH - hours
	MM - minutes
	SS - seconds
	sss- milliseconds

REV.HIST:
__Date__________Project_____Developer_______Comment_____________________
  08/08/2006	EDU046		psmart			o Read the batch run date from the adm40t_grpprof table
											o Added more comments and summary of the code.
  08/09/2006	EDU046		psmart			o Changed formatting of times so they can be imported into Excel.
											o Added a section just for importing into Excel
===========================================================================*/
SET NOCOUNT ON

DECLARE @firstJob				VARCHAR(8)		-- 
SET @firstJob = 'INBRCHD1'

DECLARE @batchRunDate			DATETIME		-- 
DECLARE @startDateTime			DATETIME
DECLARE @endDateTime			DATETIME

SET @startDateTime		= (select strt_dt from utl19t_parmsjobprogress (nolock) where job = @firstJob)

SET @endDateTime		= (select end_dt from utl19t_parmsjobprogress UTL19 (nolock)
							where UTL19.strt_dt = (select MAX(strt_dt)
													from utl19t_parmsjobprogress (nolock)
													where strt_dt >= @startDateTime))

SET @batchRunDate		= (SELECT btch_run_dt FROM adm40t_grpprof)

--======= CONSTANTS ==========================================
DECLARE @milliSecondsPerDay		FLOAT
DECLARE @secondsPerDay			FLOAT
DECLARE @mm_dd_yyyy				INT
DECLARE @HH_MM_SS_mmm			INT

SET @secondsPerDay			= 86400.0
SET @milliSecondsPerDay		= @secondsPerDay * 1000
SET @mm_dd_yyyy				= 101
SET @HH_MM_SS_mmm			= 14

--======= HEADER =============================================

PRINT ''
PRINT 'Server         : ' + @@SERVERNAME
PRINT ''
PRINT 'Right NOW      : ' + CONVERT(VARCHAR(13), GETDATE(), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), GETDATE(), @HH_MM_SS_mmm) + ' (' + CONVERT(VARCHAR(30), GETDATE(), 9) + ')'
PRINT 'Batch Run Date : ' + CONVERT(VARCHAR(13), @batchRunDate, @mm_dd_yyyy)
PRINT 'Search Start   : ' + CONVERT(VARCHAR(13), @startDateTime, @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), @startDateTime, @HH_MM_SS_mmm)
PRINT 'Search End     : ' + CONVERT(VARCHAR(13), @endDateTime, @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), @endDateTime, @HH_MM_SS_mmm)
PRINT ''
PRINT '  (Search Start and End include ALL jobs (including the extract jobs - ALL means ALL)'
PRINT ''
PRINT '   * ''Real Time'' for the jobs that DID finish.'
PRINT '     (This is also skewed for jobs that were restarted, because you lose the time of the partial run that occurred.'
PRINT '      This also does not include the startup and shutdown of MultiTH.)'
PRINT ''

--======= SUMMARY =============================================
/*	This section is just in case the @startDateTime and @endDateTime are hardcoded or calculated some
	other way than by the first and last jobs
*/

SELECT
	-- Formatting note:  When the day is the same as the run date then display a '  ' otherwise otherwise
	-- display '+ '
	  CASE WHEN (DATEPART(DD, MIN(strt_dt)) = DATEPART(DD, @startDateTime))
		THEN
			CONVERT(VARCHAR(13), MIN(strt_dt), @HH_MM_SS_mmm)
		ELSE
			CONVERT(VARCHAR(13), @startDateTime, @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), MIN(strt_dt), @HH_MM_SS_mmm)
		END
 	AS 'Started'
	, CASE WHEN (DATEPART(DD, MAX(end_dt)) = DATEPART(DD, @startDateTime))
		THEN
			CONVERT(VARCHAR(13), MAX(end_dt), @HH_MM_SS_mmm)
		ELSE
			CONVERT(VARCHAR(13), MAX(end_dt), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), MAX(end_dt), @HH_MM_SS_mmm)
		END
	AS 'Ended'
 	, CONVERT(VARCHAR(13), FLOOR(
		DATEDIFF(ms, MIN(strt_dt),
			CASE WHEN MAX(end_dt) = '12/31/9999' THEN
				MAX(strt_dt)
			ELSE
				MAX(end_dt)
			END
		) / @milliSecondsPerDay)
	  ) + 'd' +
	  CONVERT(VARCHAR(13), CONVERT(DATETIME,
		DATEDIFF(ms, MIN(strt_dt),
			CASE WHEN MAX(end_dt) = '12/31/9999' THEN
				MAX(strt_dt)
			ELSE
				MAX(end_dt)
			END
		) / @milliSecondsPerDay), @HH_MM_SS_mmm)
 	AS 'Elapsed'
--	, MAX(strt_dt)
--	, MAX(end_dt)
	, CONVERT(VARCHAR(13), CONVERT(DATETIME,
		SUM(
			CASE WHEN end_dt = '12/31/9999' THEN
				0
			ELSE
				DATEDIFF(ms, strt_dt, end_dt)
			END
		) / @milliSecondsPerDay), @HH_MM_SS_mmm)
	AS 'RealTime*'
-- 	, CONVERT(VARCHAR(13), CONVERT(DATETIME, (DATEDIFF(s, MIN(strt_dt), MAX(end_dt)) - SUM(DATEDIFF(s, strt_dt, end_dt))) / @secondsPerDay), @HH_MM_SS_mmm)
-- 	AS 'Delays'
FROM utl19t_parmsjobprogress (nolock)
WHERE		strt_dt BETWEEN @startDateTime AND @endDateTime
--AND		job not in ('EXBADM40')
AND			job not like 'EXB%'

--======= DETAIL =============================================

SELECT --TOP 10
	  CONVERT(CHAR(10), job)
	AS '   JOB'
--	, lower_limit
--	, nbr_submitted
	, CASE err_indc WHEN 0 THEN '0' ELSE '!!ERR !!' END
	AS 'err_indc'
	-- Formatting note:  When the day is the same as the run date then display a '  ' otherwise otherwise
	-- display '~ '
	, CASE WHEN (DATEPART(DD, strt_dt) = DATEPART(DD, @startDateTime))
		THEN
			'  ' + RIGHT(CONVERT(VARCHAR(32), strt_dt, 121), 12)
		ELSE
			'~ ' + RIGHT(CONVERT(VARCHAR(32), strt_dt, 121), 12)
		END
	AS 'strt_dt'
	-- Formatting note:  When the day is the same as the run date then display a '  ' otherwise otherwise
	-- display '~ '
	, CASE WHEN (DATEPART(DD, end_dt) = DATEPART(DD, @startDateTime))
		THEN
			'  ' + RIGHT(CONVERT(VARCHAR(32), end_dt, 121), 12)
		ELSE
			'~ ' + RIGHT(CONVERT(VARCHAR(32), end_dt, 121), 12)
		END
	AS 'end_dt'
	, CASE WHEN (end_dt < '12/31/9999') THEN
		RIGHT(CONVERT(VARCHAR(32), CONVERT(DATETIME, DATEDIFF(ms, strt_dt, end_dt) / @milliSecondsPerDay), 121), 12)
	  ELSE
		'NOT FINISHED'
	  END
	AS 'Elapsed'
 	, CONVERT(VARCHAR(13),
		CONVERT(DATETIME,
			DATEDIFF(ms, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 WHERE U19.strt_dt > UTL19.end_dt))
			 / @milliSecondsPerDay), @HH_MM_SS_mmm)
		+ ' '
		+ CASE
			WHEN (DATEDIFF(s, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 (NOLOCK) WHERE U19.strt_dt > UTL19.end_dt)) > 3000)
		THEN
				'!!!'
			WHEN (DATEDIFF(s, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 (NOLOCK) WHERE U19.strt_dt > UTL19.end_dt)) > 600) THEN
				'!! '
			WHEN (DATEDIFF(s, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 (NOLOCK) WHERE U19.strt_dt > UTL19.end_dt)) > 300) THEN
				'!  '
			WHEN (DATEDIFF(s, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 (NOLOCK) WHERE U19.strt_dt > UTL19.end_dt)) > 60) THEN
				'+  '
			WHEN (DATEDIFF(s, UTL19.end_dt, (SELECT MIN(strt_dt) FROM utl19t_parmsjobprogress U19 (NOLOCK) WHERE U19.strt_dt > UTL19.end_dt)) > 15) THEN
				'.  '
			ELSE
				'   '
			END

 	AS 'Delay Next'
	, strt_dt AS 'Started'
FROM
	utl19t_parmsjobprogress UTL19 (NOLOCK)
WHERE strt_dt BETWEEN @startDateTime AND @endDateTime
--AND		job not in ('EXBADM40')
AND		job not like 'EXB%'
ORDER BY Started --DESC

--======= LEGEND =============================================

PRINT 'Legend:'
PRINT '  >15 sec      .'
PRINT '  >1  min      +'
PRINT '  >5  min      !'
PRINT '  >10 min      !!'
PRINT '  >30 min      !!!'

PRINT ''
PRINT '========================= EXCEL IMPORT =================================='

SELECT --TOP 10
		  CONVERT(VARCHAR(10), job)			AS 'job'
		, strt_dt
		, end_dt
FROM		utl19t_parmsjobprogress UTL19 (NOLOCK)
WHERE	strt_dt BETWEEN @startDateTime AND @endDateTime
AND		job not like 'EXB%'
ORDER BY strt_dt --DESC