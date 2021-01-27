/*===========================================================================
AUTHOR:		Parker Smart
CREATED:	04/15/2004
PURPOSE:	A utility script that will extract data from a table

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! NOTE: Make sure that on the "Options / Results" pane that the 
!!	"Maximum characters per column is set to 2048 or larger.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USAGE:		Since this is not a stored procedure (yet) you may want to
		set some options by hand.  See below.
REV.HIST:
04/15/2004	P.Smart		Added a "prettier listing" (Kurt Style)
				(Each column is on its own line)
===========================================================================*/

DECLARE @theColumns	VARCHAR(256)
DECLARE @theWhere	VARCHAR(256)
DECLARE @skippedColumns	VARCHAR(256)
DECLARE @theTypes	VARCHAR(256)
DECLARE @theSelect	VARCHAR(2048)
DECLARE @theExec	VARCHAR(4096)
DECLARE @newLine	VARCHAR(1)
DECLARE @tab		VARCHAR(1)
DECLARE @columnName	SYSNAME
DECLARE @columnType	INT
DECLARE @columnCount	INT
DECLARE @dataWidth	VARCHAR(8)
DECLARE @tableName	SYSNAME
--DECLARE @autoVal	VARBINARY
DECLARE @autoVal	SMALLINT
DECLARE @rowCount	INT
DECLARE @formatOutput	INT		-- To save vertical space set this to 0
DECLARE @identityInsert	INT		-- To preserve the Identity IDs, set this to 1

SET @formatOutput	= 0
--SET @formatOutput	= 1
SET @identityInsert	= 0
--SET @identityInsert	= 1
SET @tableName		= 'bat01t_excpmessage'
SET @theWhere		= ''
SET @theWhere		= 'WHERE lst_updt_userid = ''3365'''
SET @theColumns		= ''
SET @skippedColumns	= ''
SET @theTypes		= ''
SET @theSelect		= ''
SET @tab		= '	'
SET @newLine		= '
'
SET @columnCount	= 0
SET @dataWidth		= '80'	-- This should be calculated.

IF (@formatOutput = 0)
BEGIN
	SET @newLine = ''	-- Set both of these to spaces to turn off formatting and save space.
	SET @tab = ''
END

/****
	NEED to find out what the primary key is and use this in the UPDATE's where clause.
***/

/* Build the SELECT columns
*/

DECLARE theCursor CURSOR FOR
select
	  sc.name 	as "Column"
	, sc.xtype 	as "Type"
	, sc.colstat 	as "AutoVal"
from 	  sysobjects so
	, syscolumns sc
where 	so.id 		= sc.id
and	so.xtype 	= 'U'
and	so.name 	= @tableName
--order by sc.colorder

OPEN theCursor

FETCH NEXT FROM theCursor INTO @columnName, @columnType, @autoVal

WHILE (@@FETCH_STATUS = 0)
BEGIN
	-- Need to skip the identity column
	-- And any other column deemed necessary.

	IF ((@autoVal = 0 OR @identityInsert = 1)) -- AND @columnName != 'lst_updt_userid' AND @columnName != 'lst_updt_tmestmp')
	BEGIN
		-- Add all the separators.
		IF (@theColumns != '') 	SET @theColumns = @theColumns + @newLine + @tab + ', '
		IF (@theTypes != '') 	SET @theTypes = @theTypes + ', '
		IF (@theSelect != '') 	SET @theSelect = @theSelect + ' + ''' + @newLine + @tab + ', '
	
		-- 1) The CONVERT(CHAR(dataWidth), ...  formats the output so the column name can be appended at the end and it lines up nicely
		-- 2) The CASE was used for the character data because the result of the ISNULL was a quoted NULL and I didn't want that quoted twice (''NULL'').

		IF (@columnType = 167 OR @columnType = 175)	-- Character data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + @columnName + ' = '' + CASE ISNULL(' + @columnName + ', ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + RTRIM(' + @columnName + ') + '''''''' END'
			ELSE
				SET @theSelect = @theSelect +  @columnName + ' = '' + CONVERT(CHAR(' + @dataWidth + '), '
					+ 'CASE ISNULL(' + @columnName + ', ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + RTRIM(' + @columnName + ') + '''''''' END) + ''-- ' + @columnName + ''''

			--SET @theSelect = @theSelect + ''''''''' + ' + @columnName + ' + '''''''''
		END
		ELSE IF	(@columnType = 61)			-- Date data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + @columnName + ' = '' + CASE ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR, ' + @columnName + ') + '''''''' END'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), '
					+ 'CASE ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR, ' + @columnName + ') + '''''''' END) + ''-- ' + @columnName + ''''
		END
		ELSE						-- Numeric data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + @columnName + ' = '' + ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''NULL'')'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''NULL'')) + ''-- ' + @columnName + ''''
		END
	
		SET @theColumns = @theColumns + @columnName
		SET @theTypes = @theTypes + CONVERT(VARCHAR, @columnType)	
	END --IF
	ELSE
	BEGIN
	-- The CURSOR will always return all of the columns and they are filtered out above.
	-- These skipped columns are mentioned in the extract.
		IF (@skippedColumns != '') 	SET @skippedColumns = @skippedColumns + ', '
		SET @skippedColumns = @skippedColumns + @columnName
	END
	FETCH NEXT FROM theCursor INTO @columnName, @columnType, @autoVal
END

CLOSE theCursor
DEALLOCATE theCursor

-- Create the SELECT statement which generates the "INSERT" output.

SET @theExec = 'SELECT ''' + @newLine + 'UPDATE ' + @tableName + ' ' + @newLine
		+ @tab + 'SET ' + @theSelect
		+ ' FROM ' + @tableName

IF (@theWhere != '') SET @theExec = @theExec + ' ' + @theWhere

IF (@skippedColumns = '') SET @skippedColumns = 'No columns were skipped.'

/*
IF (@theWhere != '')
	SET @rowCount = EXEC('SELECT COUNT(*) FROM ' + @tableName + ' ' + @theWhere)
ELSE
	SET @rowCount = EXEC('SELECT COUNT(*) FROM ' + @tableName)
END
*/

/**/
PRINT ''
PRINT '_______________Some DEBUG info________________'
PRINT '(' + @theColumns + ')'
PRINT '(' + @theTypes + ')'
PRINT @theSelect

PRINT @theExec
PRINT ''
PRINT ''
PRINT '_______________The Data________________'
/**/
PRINT '----------------------------------------------------------------------------'
PRINT '-- TABLE:        ' + @tableName
PRINT '-- COLS SKIPPED: ' + @skippedColumns
PRINT '-- DATE:         ' + CONVERT(varchar, getdate())
PRINT '-- USER:         ' + user_name()
PRINT '-- '
PRINT '-- *The following data was extracted using "Extract Data As Updates.sql" by P.Smart'

IF (@identityInsert = 1)
BEGIN
	PRINT ''
	PRINT 'SET IDENTITY_INSERT ' + @tableName + ' ON'
END

EXEC (@theExec)

IF (@identityInsert = 1) PRINT 'SET IDENTITY_INSERT ' + @tableName + ' OFF'

PRINT 'GO'

GO
