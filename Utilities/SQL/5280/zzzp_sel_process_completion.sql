if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[zzzp_sel_process_completion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[zzzp_sel_process_completion]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*************************************************************************************
** proc name:	zzzp_sel_process_completion
**
** Description: 	
**
** Input Parameters:
**	parm		 type		contains
**	-------		 ------		-------------------------
**	@pJobName	varchar(32)	Name of job
**	@pNoteBased	int			0: Parti based 1: Note based.
**	@pRestartID	int			Note ID
**
** Output:	None
** 
** History:
** Name		      Date          Pr Number     Description
** ------------   ------------  -----------   -------------------------
** P.Smart        12/19/2003	16501         Initial Version
** P.Smart        10/09/2004    .Net          Display HH:MM:SS elapsed time.
**                                            Added pNoteBased parm.
** P.Smart        10/19/2004    .Net          Display HH:MM:SS estimated completion time.
**
*************************************************************************************/
CREATE proc dbo.zzzp_sel_process_completion

  @pJobName			varchar(32)
, @pNoteBased	 	int				-- 0: Parti based 1: Note based.
, @pRestartID		int = 0
as

declare @allNotes			float
declare @doneNotes			float
declare @elapsedMinutes		float
declare @elapsedSeconds		float
declare @lastIDProcessed	int
declare @remainingIDs		float
declare @jobName			varchar(10)
declare @dateStart			datetime
declare @dateEnd			datetime
DECLARE @secondsPerDay		float
declare @idText				varchar(10)
declare @maxID				int

DECLARE @HH_MM_SS_mmm		INT
SET 	@HH_MM_SS_mmm		= 14

SET @secondsPerDay	= 86400.0

set @jobName		= @pJobName		--<<<<<< ENTER Job Name (used to be a manual SQL script)
--set @lastNoteProcessed	= @pLastNoteID	--<<<<<< ENTER The ID of the last note processed from the SQL Trace.
set @lastIDProcessed	= (select lower_limit from utl19t_parmsjobprogress (nolock) where job = @pJobName)

print 'Time Now             : ' + cast(getdate() 			as varchar(32))
print 'Job Name             : ' + cast(@jobName 				as varchar(32))
if (@pNoteBased = 1)
BEGIN
	set @maxID	 		= (select max(note_id) FROM nte01t_note (nolock))
	set @idText = 'Note'
END
ELSE
BEGIN
	set @maxID	 		= (select max(parti_id) FROM prt01t_participant (nolock))
	set @idText = 'Parti'
END

print 'MAX ' + @idText + ' ID          : ' + cast(@maxID 	as varchar(32))
print 'Last ' + @idText + ' ID         : ' + cast(@lastIDProcessed 	as varchar(32))
print '(Re)start ' + @idText + ' ID    : ' + cast(@pRestartID		 	as varchar(32))
print ''


set @dateEnd = (select end_dt  from utl19t_parmsjobprogress (nolock) where job = @jobName)

if (@dateEnd = cast('12/31/9999' as datetime))
begin
	set @dateStart		= (select strt_dt from utl19t_parmsjobprogress (nolock) where job = @jobName)
	set @elapsedMinutes 	= DATEDIFF(minute, @dateStart, getdate())
	set @elapsedSeconds 	= DATEDIFF(second, @dateStart, getdate())

	if (@pNoteBased = 1)
	begin
		set @allNotes 		= (select count(*) FROM nte01t_note (nolock))
		set @remainingIDs 	= (select count(*) FROM nte01t_note (nolock) where note_id > @pRestartID)
		set @doneNotes 		= (select count(*) FROM nte01t_note (nolock) where note_id < @lastIDProcessed)
	end
	else
	begin
		set @allNotes 		= (select count(*) FROM prt01t_participant (nolock))
		set @remainingIDs 	= (select count(*) FROM prt01t_participant (nolock) where parti_id > @pRestartID)
		set @doneNotes 		= (select count(*) FROM prt01t_participant (nolock) where parti_id < @lastIDProcessed)
	end
	
	print @idText + ' Total           : ' + cast(@allNotes as varchar(32))
	print @idText + 's Completed      : ' + cast(@doneNotes as varchar(32)) + ' (' + cast(@doneNotes / @allNotes * 100 as varchar(32)) + '%)'
	print ''
--	print 'Elapsed Minutes      : ' + cast(@elapsedMinutes as varchar(32))
	print '                      (HH:MM:SS)'
	print 'Elapsed Time         : ' + CONVERT(VARCHAR(13), CONVERT(datetime, @elapsedSeconds / @secondsPerDay), @HH_MM_SS_mmm)
	if (@doneNotes = 0)
	begin
		print 'Est. Completion Minutes : (undetermined -- no ' + @idText + '  completed)'
	end
	else
	begin
--		print 'Est. Completion Minutes : ' + cast(@elapsedMinutes * (@allNotes - @doneNotes) / (@remainingIDs - (@allNotes - @doneNotes)) as varchar(32))
		print 'Completion Time      : ' + CONVERT(VARCHAR(16),
				CONVERT(DATETIME, @elapsedMinutes * (@allNotes - @doneNotes) / (@remainingIDs - (@allNotes - @doneNotes)) * 60 / @secondsPerDay), @HH_MM_SS_mmm)
	end
end
else
begin
	print 'The process has completed.'
end
GO
