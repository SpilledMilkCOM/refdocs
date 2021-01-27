/*
Authors:	David Utley, Parker Smart

Purpose:	This script will generate a script to adjust all of the permissions for
			tables, view, and stored procedures.
*/

DECLARE @newLine		AS VARCHAR(2)

SET @newLine='
'

SET NOCOUNT ON

--====== Generate the permissions for TABLES

select 'grant select on ' + name + ' to user_grp' + @newLine +
	'go' + @newLine +
	'grant select on ' + name + ' to pgmr_grp' + @newLine +
	'go' + @newLine +
	'grant insert, update, delete, references, select on ' + name + ' to ecsbatch_grp' + @newLine +
	'go'
from sysobjects
where type = 'U'

--====== Generate the permissions for VIEWS

select	'grant select on [dbo].[' + name + '] to ecsbatch_grp' + @newLine +
	'go' + @newLine +
	'grant select on [dbo].[' + name + '] to pgmr_grp' + @newLine +
	'go' + @newLine +
	'grant select on [dbo].[' + name + '] to user_grp' + @newLine +
	'go'
from sysobjects 
where 	xtype = 'V'
and 	uid = 1 
and 	status > 0

--====== Generate the permissions for STORED PROCEDURES

select	'grant execute on [dbo].[' + name + '] to ecsbatch_grp' + @newLine +
	'go' + @newLine +
	'grant execute on [dbo].[' + name + '] to user_grp' + @newLine +
	'go'
/*
select	'grant execute on [dbo].[' + name + '] to pgmr_grp' + @newLine +
	'go' + @newLine
from sysobjects 
where 	xtype = 'P'
and 	uid = 1 
and 	status > 0
and name in (
'filp_del_fil04t',
'filp_ins_fil04t_mini',
'filp_ins_fil05t_minierr',
'filp_ins_fil13t_load_file',
'filp_sel_fil01t_with_errors',
'filp_sel_fil02_details',
'filp_sel_fil03t_with_errors',
'filp_sel_fil05t',
'filp_sel_fil11t_file_base',
'filp_sel_fil13t_load_file',
'filp_sel_fil15t_recd_info',
'filp_sel_fil16t_file_base_map',
'filp_sel_fil20t_reversals_by_file',
'filp_sel_fil20t_reversal_files',
'filp_sel_file_id',
'filp_sel_get_next_mini_file',
'filp_sel_max_table_id',
'filp_upd_fil03t_resubmit_file',
'filp_upd_fil13t_load_file_processed_date',
'filp_upd_fil20t_reversal_processed_date',
'filp_ins_fil01t_filereceive',
'filp_ins_file02t_dtl',
'ntep_sel_duplicate_file',
'filp_sel_nte21t_by_partipmt',
'filp_updt_fil01t_backupname',
'filp_upd_fil01t_file_totals',
'filp_upd_fil01t_nbr_of_files',
'filp_upd_fil01t_sender',
'prtp_sel_current_ppid'
)
*/