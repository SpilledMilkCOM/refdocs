-----------------------------------------------------------------------------------------------------------
-- Author:		Parker Smart
-- Date:		12/22/2005
-- Description:	The following code GENERATES SQL code to summarize information for each column of a table.
--

DECLARE @table_name			AS VARCHAR(32)
SET		@table_name 		= 'wrk71t_chela_mast'
DECLARE @group_max			AS VARCHAR(4)
SET 	@group_max			= '200'
DECLARE @col_width			AS VARCHAR(4)
SET 	@col_width			= '32'

SET NOCOUNT ON

DECLARE @mm_dd_yyyy			INT
DECLARE @HH_MM_SS_mmm		INT
SET 	@mm_dd_yyyy		= 101
SET 	@HH_MM_SS_mmm	= 14


DECLARE @newLine	AS CHAR(1)
SET		@newLine = '
'
DECLARE @TAB		AS CHAR(1)
SET		@TAB = '	'

PRINT '----------------------------------------------------------------------------'
PRINT '-- DATE:         ' + CONVERT(VARCHAR(13), getdate(), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), getdate(), @HH_MM_SS_mmm)
PRINT '-- USER:         ' + user_name()
PRINT '--'
PRINT '-- This file generated by "View Tables - Generate Column Summary.sql" Created by P.Smart'
PRINT '--'
PRINT ''

PRINT 'SET NOCOUNT ON'
PRINT ''
PRINT 'PRINT ''Started: '' + CONVERT(VARCHAR(13), getdate(), 101) + '' '' + CONVERT(VARCHAR(13), getdate(), 14)'
PRINT 'PRINT '''''
PRINT 'GO'
PRINT ''
PRINT 'DECLARE @table_count		AS INT'
PRINT ''
PRINT 'SET @table_count = (SELECT COUNT(*) FROM ' + @table_name + ')'
PRINT 'PRINT ''Count of ' + @table_name + ' = '' + CONVERT(VARCHAR(32), @table_count)'
PRINT 'PRINT '''''
PRINT 'GO'
PRINT ''

select 	'/*--------------------------------------------------------------------------------------------------- ' + sc.name + ' */' + @newLine
		+ @newLine
		+ 'DECLARE @column_count		AS INT'  + @newLine
		+ 'DECLARE @group_count		AS INT'  + @newLine
		+ 'DECLARE @table_count		AS INT'  + @newLine
		+ 'DECLARE @one_value			AS VARCHAR(1024)'  + @newLine
		+ @newLine
		+ 'SET @table_count 	= (SELECT COUNT(*) FROM ' + @table_name + ')' + @newLine
		+ 'SET @column_count 	= (SELECT COUNT(*) FROM ' + @table_name + ' (NOLOCK) WHERE ' + sc.name + ' IS NOT NULL)' + @newLine
		+ @newLine
		+ 'IF (@column_count <> @table_count)' + @newLine
		+ 'BEGIN' + @newLine
		+ @TAB + 'PRINT CONVERT(CHAR(' + @col_width + '), ''' + sc.name + ''') + ''Count = '' + CONVERT(VARCHAR(32), @column_count)' + @newLine
		+ 'END' + @newLine
		+ @newLine
		+ 'SET @group_count = (SELECT COUNT(*) FROM (SELECT ' + sc.name + ' AS ''Summarizing ' + sc.name + ''', COUNT(*) AS ''Count of ' + sc.name + '''' + @newLine
			+ @TAB + @TAB + @TAB + @TAB + 'FROM ' + @table_name + ' WHERE br_dmg_zip IS NOT NULL GROUP BY ' + sc.name + ') tmp)' + @newLine
		+ 'IF (@group_count = 1)' + @newLine
		+ 'BEGIN' + @newLine
		+ @TAB + 'SET @one_value = (SELECT DISTINCT ' + sc.name + ' FROM ' + @table_name + ')' + @newLine
		+ @TAB + 'PRINT CONVERT(CHAR(' + @col_width + '), ''' + sc.name + ''') + ''All non NULL values were the same. '''''' + @one_value + ''''''''' + @newLine
		+ 'END' + @newLine
		+ 'ELSE IF (@group_count < @column_count AND @group_count < ' + @group_max + ')' + @newLine
		+ 'BEGIN' + @newLine
--		+ @TAB + 'SET NOCOUNT OFF' + @newLine
		+ @TAB + 'PRINT CONVERT(CHAR(' + @col_width + '), ''' + sc.name + ''') + ''Summary rows = '' + CONVERT(VARCHAR(32), @group_count)' + @newLine
		+ @TAB + 'SELECT ' + sc.name + ' AS ''' + sc.name + ''', COUNT(*) AS ''Count of ' + sc.name + '''' + @newLine
			+ @TAB + @TAB + @TAB + @TAB + 'FROM ' + @table_name + ' WHERE br_dmg_zip IS NOT NULL GROUP BY ' + sc.name + ' ORDER BY ' + sc.name + @newLine
--		+ @TAB + 'SET NOCOUNT ON' + @newLine
		+ 'END' + @newLine
		+ 'ELSE IF (@group_count = @column_count)' + @newLine
		+ @TAB + 'PRINT CONVERT(CHAR(' + @col_width + '), ''' + sc.name + ''') + ''All non NULL values unique.''' + @newLine
		+ 'ELSE IF (@group_count >= ' + @group_max + ')' + @newLine
		+ @TAB + 'PRINT CONVERT(CHAR(' + @col_width + '), ''' + sc.name + ''') + ''Group summary was >= ' + @group_max + '''' + @newLine
		+ 'GO' + @newLine
		+ @newLine
	
from	sysobjects so
JOIN	syscolumns sc
		ON sc.id = so.id
where	so.xtype = 'U'
and		so.name = @table_name
order by sc.colorder

