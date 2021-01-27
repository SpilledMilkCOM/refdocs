if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[zzzp_extract_data_as_inserts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[zzzp_extract_data_as_inserts]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*==========================================================================================================================
AUTHOR:		Parker Smart
CREATED:	04/15/2004
PURPOSE:	A utility script that will extract data from a table and create INSERT statements for them.

NOTES:		1) Set the query output to TEXT.
			2) Verify that your output is not clipped.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! NOTE: Make sure that on the "Options / Results" pane that the 
!!	"Maximum characters per column" is set to 2048 or larger.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USAGE:		Since this is not a stored procedure (yet) you may want to set some options by hand.  See below.

Planned Revisions:
	1) When formatting the output add leader lines on every other value line to match up the comment with the value better.
	2) Calculate the maximum width of the data to set the formatting appropriately.
	3) Add row count to the header information.
	4) Attempt to automatically adjust the environment to switch to text output and change the column width that is larger (if needed).

__DATE______FIXED_______REVISION_HISTORY________________________________________________________________
04/20/2004	P.Smart		Added a "prettier listing" (Kurt Style - adding comments was MY idea though)
						(Each column is on its own line - saves on horizontal space)
12/10/2004  P.Smart		Sort the cursor by 'colorder' - The ordinal value of the column.
12/28/2004	P.Smart		Added RESTRICTIONS: text to comment header in the output.
12/30/2004	P.Smart		Wrap the INSERTs in a transaction.
12/31/2004	P.Smart		FORMATED OUTPUT ONLY: Toggle comment style    / * column_name * /   OR   -- column_name
01/01/2005  P.Smart		!! ====>>>>>> Setup www.PayPal.com account for "time saved" donations -- psmart@SpilledMilk.com
01/27/2005  P.Smart		Added existence check on @theWhere before it's concatenated (per. D.Utley)
02/10/2005	P.Smart		Increased the buffer sizes to handle more columns. (K.Devlin found this)
02/10/2005	P.Smart		Changed @tableName from a SYSNAME to VARCHAR(64) due to concatenation problems with large amounts of text.
02/14/2005	P.Smart		Changed @columnName from a SYSNAME to VARCHAR(64) same as above /|\. (B.Rausch found this)
06/30/2005	P.Smart		Need to QuoteQuote() Change ' -- '' in the data (ex: Conan O'Brian --> Conan O''Brian
07/06/2005  P.Smart		Added "Flush First"  -- (delete from <<table>>)
==============================================================================================================================*/

CREATE PROC dbo.zzzp_extract_data_as_inserts
  @tableName			VARCHAR(64)			-- Table name from which to extract 
, @theWhere				VARCHAR(256)		-- Restrict the extract to certain rows (SAMPLES below)
, @flushFirst			INT					-- Delete existing rows before the inserts
, @formatOutput			INT					-- To save vertical space set this to 0 (a value of 1 will "Pretty Print"
, @formatCommentStyle	INT					-- Toggle comment style (0 - end of line / 1 - "old school")
, @dataWidth			VARCHAR(8)			-- Format Only: Maximum width of the data so the column comments line up.
											-- 		(Make this value smaller if the comments are too far away from your values)
, @identityInsert		INT					-- To preserve the Identity IDs, set this to 1
, @wrapInTransaction	INT					-- Generate transaction code around all of the inserts (if set to 1)
AS

-- SAMPLE WHERE clauses (must include the keyword 'WHERE'
--		'WHERE cde_type IN (''AA'', ''AP'') ORDER BY seq_nbr'		-- SAMPLE: Don't forget to escape the quote with a quote.
--		'WHERE (remotg_grp = ''prod'')'								-- SAMPLE: A normal old WHERE clause (comment out if no restrictions are needed)


------------------------------------------------------------------------------------------------------------------------
/*========================== EDIT BELOW THIS LINE AT YOU'RE OWN RISK =================================================*/
------------------------------------------------------------------------------------------------------------------------
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @theColumns			VARCHAR(1024)
DECLARE @skippedColumns		VARCHAR(256)
DECLARE @theTypes			VARCHAR(512)
DECLARE @theBuffer			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @theSelect			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @theExec			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @newLine			VARCHAR(1)
DECLARE @tab				VARCHAR(1)
DECLARE @separator			VARCHAR(128)
DECLARE @columnComment		VARCHAR(128)
DECLARE @columnName			VARCHAR(64)
DECLARE @columnType			INT
DECLARE @columnCount		INT
DECLARE @autoVal			SMALLINT
DECLARE @rowCount			INT
DECLARE @mm_dd_yyyy			INT
DECLARE @HH_MM_SS_mmm		INT

SET @theColumns		= ''
SET @skippedColumns	= ''
SET @theTypes		= ''
SET @theSelect		= ''
SET @tab			= '	'
SET @newLine		= '
'
SET @columnCount	= 0
SET @mm_dd_yyyy		= 101
SET @HH_MM_SS_mmm	= 14

IF (@formatOutput = 0)
BEGIN
	SET @newLine 	= ''	-- Set both of these to spaces to turn off formatting and save space.
	SET @tab 		= ''
	SET @separator 	= ''
END
ELSE
BEGIN
	-- If you're not in a transaction adding the GO statement will give you immediate feedback that something is happening.
	
	SET @separator		= @newLine
	
	IF (@wrapInTransaction = 0)
	 	SET @separator = @separator + 'GO' + @newLine
	
	SET  @separator = @separator + '--------------------------------------------------------------------------------'
END

/*
 * Build the SELECT columns
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
order by sc.colorder

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
		IF (@theSelect != '') 	SET @theSelect = @theSelect + ' + ''' + @newLine + @tab + ', '' + '

		IF (@formatOutput = 1)
		BEGIN
			IF (@formatCommentStyle = 0)
				SET @columnComment = '-- ' + @columnName
			ELSE
				SET @columnComment = '/* ' + @columnName + ' */'
		END

	
		-- 1) The CONVERT(CHAR(dataWidth), ...  formats the output so the column name can be appended at the end and it lines up nicely
		-- 2) The CASE was used for the character data because the result of the ISNULL was a quoted NULL and I didn't want that quoted twice (''NULL'').

		IF (@columnType = 167 OR @columnType = 175)			--======================= Character data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + 'CASE ISNULL(' + @columnName + ', ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + REPLACE(RTRIM(' + @columnName + '), '''''''', '''''''''''') + '''''''' END'
			ELSE
			BEGIN
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), ' + 'CASE ISNULL(' + @columnName
							+ ', ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + REPLACE(RTRIM(' + @columnName + '), '''''''', '''''''''''') + '''''''' END) + ''' + @columnComment + ''''
			END

			-- Keep for debugging.
			--SET @theSelect = @theSelect + ''''''''' + ' + @columnName + ' + '''''''''
		END
		ELSE IF (@columnName = 'lst_updt_tmestmp')
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + '''getdate()'''
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), ''getdate()'') + ''' + @columnComment + ''''
		END
		ELSE IF	(@columnType = 61 OR @columnType = 58)		--======================= Date data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + 'CASE ISNULL(CONVERT(VARCHAR, ' + @columnName + ', 20), ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR, ' + @columnName + ', 20) + '''''''' END'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), '
					+ 'CASE ISNULL(CONVERT(VARCHAR, ' + @columnName + ', 20), ''SQLVALUE_NULL'') WHEN ''SQLVALUE_NULL'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR, ' + @columnName + ', 20) + '''''''' END) + ''' + @columnComment + ''''
		END
		ELSE												--======================= Numeric data...
		BEGIN
			IF (@formatOutput = 0)
				SET @theSelect = @theSelect + 'ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''NULL'')'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), ISNULL(CONVERT(VARCHAR, ' + @columnName + '), ''NULL'')) + ''' + @columnComment + ''''
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

SET @theExec = 'SELECT CONVERT(VARCHAR(8000), ''' + @newLine + 'INSERT INTO ' + @tableName + ' ' + @newLine
		+ @tab + '( ' + @theColumns + @newLine+ @tab + ') ' + @newLine
		+ 'VALUES ' + @newLine
		+ @tab + '( '' + ' + @theSelect + ' + ''' + @newLine + @tab + ')' + @separator + ''') FROM ' + @tableName

IF (@theWhere != '' and @theWhere is not null) SET @theExec = @theExec + ' ' + @theWhere

IF (@skippedColumns = '') SET @skippedColumns = 'No columns were skipped.'

-- NOPE!
--SET @rowCount = EXEC ('SELECT COUNT(*) FROM ' + @tableName + ' ' + @theWhere)

--DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
/*
PRINT ''
PRINT '_______________Some DEBUG info________________'
PRINT 'THE COLUMNS: (' + @theColumns + ')'
PRINT 'THE TYPES:   (' + @theTypes + ')'
PRINT 'THE SELECT:'
PRINT @theSelect

PRINT 'THE EXEC:'
PRINT @theExec
PRINT ''
PRINT ''
PRINT '_______________The Data________________'
*/
--DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

PRINT '----------------------------------------------------------------------------'
PRINT '-- TABLE:        ' + @tableName
PRINT '-- COLS SKIPPED: ' + @skippedColumns
PRINT '-- DATE:         ' + CONVERT(VARCHAR(13), getdate(), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), getdate(), @HH_MM_SS_mmm)
PRINT '-- USER:         ' + user_name()
PRINT '-- RESTRICTIONS: ' + @theWhere
PRINT '-- '
PRINT '-- *The following data was extracted using "Extract Data As Inserts.sql" by P.Smart'
PRINT '-- '
PRINT '--====================================================================================='

IF (@wrapInTransaction = 1)
BEGIN
	PRINT ''
	PRINT 'BEGIN TRAN'
END

IF (@identityInsert = 1)
BEGIN
	PRINT ''
	PRINT 'SET IDENTITY_INSERT ' + @tableName + ' ON'
END

IF (@flushFirst = 1)
BEGIN
	PRINT ''
	PRINT 'DELETE FROM ' + @tableName
END

SET NOCOUNT ON

EXEC (@theExec)

IF (@identityInsert = 1) PRINT 'SET IDENTITY_INSERT ' + @tableName + ' OFF'

IF (@wrapInTransaction = 1)
BEGIN
	PRINT 'IF (@@ERROR = 0)'
   	PRINT 'BEGIN'
    PRINT '	COMMIT TRAN'
    PRINT '	PRINT ''Completed Successfully'''
   	PRINT 'END'
   	PRINT 'ELSE'
   	PRINT 'BEGIN'
    PRINT '	ROLLBACK TRAN'
    PRINT '	PRINT ''Rolled back due to errors.'''
   	PRINT 'END'
END
ELSE
BEGIN
	PRINT 'GO'
END


GO
