if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[zzzp_sel_process_duration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[zzzp_sel_process_duration]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*************************************************************************************
** proc name:	zzzp_sel_process_duration
**
** Description: 	
**
** Input Parameters:
**	parm		 type		contains
**	-------		 ------		-------------------------
**	@pJobName	varchar(32)	Name of job
**	@pLastNoteID	int		Note ID
**
** Output:	None
** 
** History:
** Name		Date		Pr Number	Description
** ------------ 	------------		--------------	-------------------------
** P.Smart	12/19/2003	16501		Initial Version
**
*************************************************************************************/
CREATE proc dbo.zzzp_sel_process_duration

@pJobName		varchar(32),
@pPrevJobName	varchar(32)
as
declare @duration			int
declare @durationTotal		int
declare @endDate			datetime
declare @prevEndDate		datetime
declare @incompleteDate		datetime

set @incompleteDate = '12/31/9999'
set @durationTotal = 0

set @endDate 		= (select end_dt from utl19t_parmsjobprogress where job = @pJobName)

if (isnull(@endDate, '') <> '') begin
	set @prevEndDate	= (select end_dt from utl19t_parmsjobprogress where job = @pPrevJobName)
	
	if (@prevEndDate > @endDate)
	begin
		print 'PND''G - ' + @pJobName
	end
	else begin
		if ((select end_dt from utl19t_parmsjobprogress where job = @pJobName) = @incompleteDate)
		begin
			print 'inc   - ' + @pJobName
		end else begin
			set @duration = (select DATEDIFF(minute, strt_dt, end_dt)
					from utl19t_parmsjobprogress
					where job = @pJobName)
			print cast(@duration as char(5)) + ' - ' + @pJobName
			set @durationTotal = @durationTotal + @duration
		end
	end
end
else begin
	print 'NOTFD - ' + @pJobName
end
GO
