/*==========================================================================================================================
AUTHOR:		Parker Smart
CREATED:	04/15/2004
PURPOSE:	A utility script that will extract data from a table and create INSERT statements for them.

NOTES:		1) Set the query output to TEXT.
			2) Verify that your output is not clipped.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! NOTE: Make sure that on the "Options / Results" pane that the 
!!	"Maximum characters per column" is set to 2048 or larger.  (8192 in SQL 2005)
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
06/30/2005	P.Smart		Need to QuoteQuote() Change ' --> '' in the data (ex: Conan O'Brian --> Conan O''Brian
07/06/2005  P.Smart		Added "Flush First"  -- (delete from <<table>>)   "I like a clean bowl."  John Cage - Ally McBeal
02/06/2006	P.Smart		Added option to remove the code to handle the appostraphe replacement (Trying to handle tables with more columns).
						By removing this option, more code can be packed into that 8,000 character limitation of a VARCHAR
02/06/2006	P.Smart		Change SQLVALUE_NULL to _NUL_ in order to reduce the code and handle tables with more columns.
02/06/2006	P.Smart		Removed the spaces between the + signs, after commas, etc.  Anything to beat that 8,000 character limit
05/05/2006	P.Smart		Added the WHERE clause to the "Flush First" (DELETE) if it exists.
07/31/2006	P.Smart		Print NONE if there are no restrictions.
11/21/2006	P.Smart		Added optional newline between INSERT and VALUES. (@formatOutput = 2)
==============================================================================================================================*/

DECLARE @tableName			VARCHAR(64)		-- Table name from which to extract 
DECLARE @theWhere			VARCHAR(8000)	-- Restrict the extract to certain rows
SET		@theWhere			= ''			-- Make sure this is initialized.
DECLARE @flushFirst			INT				-- Delete existing rows before the inserts
DECLARE @formatOutput		INT				-- To save vertical space set this to 0
DECLARE @formatCommentStyle	INT				-- Toggle comment style
DECLARE @dataWidth			VARCHAR(8)		-- Format Only: Maximum width of the data so the column comments line up.
DECLARE @identityInsert		INT				-- To preserve the Identity IDs, set this to 1
DECLARE @wrapInTransaction	INT				-- Generate transaction code around all of the inserts.
DECLARE @appostraphesInData	INT				-- Reduce the logic per column for tables with lot's of columns.
DECLARE	@rtrimData			INT
DECLARE @generateCode		INT				-- The constructed code will overflow 8000 characters so dump it to the results.

SET @flushFirst				= 0
--SET @flushFirst			= 1

SET @formatOutput			= 0
SET @formatOutput			= 1
--SET @formatOutput			= 2

--SET @formatCommentStyle		= 0				-- Set to 0 for "end of line" comments
SET @formatCommentStyle		= 1				-- Set to 1 for "old school" comments

SET @identityInsert			= 0
--SET @identityInsert			= 1				-- Set this to 1 if you have an identity column where you want to keep the numbers.

SET @wrapInTransaction		= 0
--SET @wrapInTransaction	= 1				-- Set this to 1 if you want all of the inserts to be contained in a transaction (NOT TESTED).

SET @appostraphesInData		= 1				-- Set this if there are appostraphes in the data (default to 1 - better to be safe than sorry).
--SET @appostraphesInData		= 0

--SET @rtrimData				= 1				-- Set this if there are appostraphes in the data (default to 1 - better to be safe than sorry).
SET @rtrimData				= 0

SET @generateCode			= 0					-- Spit out resultant code to get around that 8,000 VARCHAR limit.
--SET @generateCode			= 1

SET @tableName		= 'adm40t_grpprof'
--SET @tableName		= 'utl19t_parmsjobprogress'
--SET @theWhere		= 'WHERE cde_type IN (''AA'', ''AP'') ORDER BY seq_nbr'		-- SAMPLE: Don't forget to escape the quote with a quote.
--SET @theWhere		= 'WHERE (remotg_grp = ''default'')'							-- SAMPLE: A normal old WHERE clause (comment out if no restrictions are needed)
--SET @theWhere		= 'WHERE note_id IN (12, 41, 2, 23)'
--SET @theWhere		= 'WHERE nbr_instances > 1'					-- SAMPLE: A normal old WHERE clause (comment out if no restrictions are needed)
--SET @theWhere = 'WHERE lst_updt_userid = ''EDU025'''
--SET @theWhere		= 'WHERE (envrnmnt = ''EDU010'')'

SET @dataWidth				= '60'			-- Might not need to change this if your character data is less than this value.
											-- (Make this value smaller if the comments are too far away from your values)

------------------------------------------------------------------------------------------------------------------------
/*========================== EDIT BELOW THIS LINE AT YOU'RE OWN RISK =================================================*/
------------------------------------------------------------------------------------------------------------------------
SET CONCAT_NULL_YIELDS_NULL OFF
SET NOCOUNT ON

DECLARE @debugOn			INT
DECLARE @theColumns			VARCHAR(1024)
DECLARE @skippedColumns		VARCHAR(256)
DECLARE @theTypes			VARCHAR(512)
DECLARE @theBuffer			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @theSelect			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @theExec			VARCHAR(8000)		-- 8000 is MAX for VARCHAR
DECLARE @newLine			VARCHAR(1)
DECLARE @tab				VARCHAR(1)
DECLARE @separator			VARCHAR(128)
DECLARE @sepInsertValue		VARCHAR(128)
DECLARE @columnComment		VARCHAR(128)
DECLARE @columnName			VARCHAR(64)
DECLARE @columnType			INT
DECLARE @columnCount		INT
DECLARE @autoVal			SMALLINT
DECLARE @rowCount			INT
DECLARE @mm_dd_yyyy			INT
DECLARE @HH_MM_SS_mmm		INT
DECLARE @charCount			INT
DECLARE @replacePre			VARCHAR(64)
DECLARE @replacePost		VARCHAR(64)
DECLARE @rtrimPre			VARCHAR(64)
DECLARE @rtrimPost			VARCHAR(64)

SET @debugOn		= 0
SET @theColumns		= ''
SET @skippedColumns	= ''
SET @theTypes		= ''
SET @theSelect		= ''
SET @tab			= '	'
SET @newLine		= '
'
SET @charCount		= 0
SET @columnCount	= 0
SET @mm_dd_yyyy		= 101
SET @HH_MM_SS_mmm	= 14

IF (@formatOutput = 0)
BEGIN
	SET @newLine 		= ''	-- Set both of these to spaces to turn off formatting and save space.
	SET @tab 			= ''
	SET @separator 		= ''
	SET @sepInsertValue = ''
END
ELSE IF (@formatOutput = 2)
BEGIN
	SET @sepInsertValue = @newLine + @tab
	SET @newLine 		= ''	-- Set both of these to spaces to turn off formatting and save space.
	SET @tab 			= ''
	SET @separator 		= ''
END
ELSE
BEGIN
	-- If you're not in a transaction adding the GO statement will give you immediate feedback that something is happening.
	
	SET @separator		= @newLine
	SET @sepInsertValue = @newLine

	IF (@wrapInTransaction = 0)
	 	SET @separator = @separator + 'GO' + @newLine

	
	SET  @separator = @separator + '--------------------------------------------------------------------------------'
END


IF (@appostraphesInData = 1)	-- This should be on by default to handle the "generic" case.
BEGIN
	SET @replacePre		= 'REPLACE('
	SET @replacePost	= ', '''''''', '''''''''''')'
END
ELSE
BEGIN
	SET @replacePre		= ''
	SET @replacePost	= ''
END

IF (@rtrimData = 1)	-- This should be on by default to handle the "generic" case.
BEGIN
	SET @rtrimPre		= 'RTRIM('
	SET @rtrimPost		= ')'
END
ELSE
BEGIN
	SET @rtrimPre		= ''
	SET @rtrimPost		= ''
END

/*
 * Build the SELECT columns
 */

DECLARE theCursor CURSOR FOR
SELECT
	  sc.name 		as "Column"
	, sc.xtype 		as "Type"
	, sc.colstat 	as "AutoVal"
FROM 	  sysobjects so
		, syscolumns sc
WHERE 	so.id 		= sc.id
AND		so.xtype 	= 'U'
AND		so.name 	= @tableName
ORDER BY sc.colorder

OPEN theCursor

FETCH NEXT FROM theCursor INTO @columnName, @columnType, @autoVal

WHILE (@@FETCH_STATUS = 0)
BEGIN
	-- Need to skip the identity column
	-- And any other column deemed necessary.

	IF ((@autoVal = 0 OR @identityInsert = 1)) -- AND @columnName != 'lst_updt_userid' AND @columnName != 'lst_updt_tmestmp')
-- 	IF ((@autoVal = 0 OR @identityInsert = 1)
-- 		AND @columnName != 'closd_reasn_cde' AND @columnName != 'sub_purpse_cde'
-- 		AND @columnName != 'ln_pln_dtl_cde' AND @columnName != 'ln_imprd_cde')
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
			IF (@formatOutput = 0 OR @formatOutput = 2)
				SET @theSelect = @theSelect + 'CASE ISNULL(' + @columnName + ',''_NUL_'') WHEN ''_NUL_'' THEN ''NULL'' ELSE ' + '''''''''+' + @replacePre + @rtrimPre + @columnName + @rtrimPost + @replacePost + '+'''''''' END'
			ELSE
			BEGIN
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '), ' + 'CASE ISNULL(' + @columnName
							+ ',''_NUL_'') WHEN ''_NUL_'' THEN ''NULL'' ELSE ' + ''''''''' + ' + @replacePre + @rtrimPre + @columnName + @rtrimPost + @replacePost + ' + '''''''' END)+''' + @columnComment + ''''
			END

			-- Keep for debugging.
			--SET @theSelect = @theSelect + ''''''''' + ' + @columnName + ' + '''''''''
		END
		ELSE IF (@columnName = 'lst_updt_tmestmp')
		BEGIN
			IF (@formatOutput = 0 OR @formatOutput = 2)
				SET @theSelect = @theSelect + '''getdate()'''
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '),''getdate()'')+''' + @columnComment + ''''
		END
		ELSE IF	(@columnType = 61 OR @columnType = 58)		--======================= Date data...
		BEGIN
			IF (@formatOutput = 0 OR @formatOutput = 2)
				SET @theSelect = @theSelect + 'CASE ISNULL(CONVERT(VARCHAR,' + @columnName + ',20),''_NUL_'') WHEN ''_NUL_'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR,' + @columnName + ',20)+'''''''' END'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '),'
					+ 'CASE ISNULL(CONVERT(VARCHAR,' + @columnName + ',20),''_NUL_'') WHEN ''_NUL_'' THEN ''NULL'' ELSE ' + ''''''''' + CONVERT(VARCHAR,' + @columnName + ',20)+'''''''' END)+''' + @columnComment + ''''
		END
		ELSE												--======================= Numeric data...
		BEGIN
			IF (@formatOutput = 0 OR @formatOutput = 2)
				SET @theSelect = @theSelect + 'ISNULL(CONVERT(VARCHAR,' + @columnName + '),''NULL'')'
			ELSE
				SET @theSelect = @theSelect + 'CONVERT(CHAR(' + @dataWidth + '),ISNULL(CONVERT(VARCHAR,' + @columnName + '),''NULL'')) + ''' + @columnComment + ''''
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


IF (@generateCode = 1)
BEGIN
	PRINT 'SELECT CONVERT(VARCHAR(8000), ''' + @newLine + 'INSERT INTO ' + @tableName
	PRINT @tab + '( ' + @theColumns
	PRINT ') VALUES '
	PRINT  @tab + '( '' + ' + @theSelect + ' + ''' + @newLine + @tab + ')' + @separator + ''') FROM ' + @tableName

	IF (@theWhere != '' and @theWhere is not null) PRINT @theWhere
END
ELSE
BEGIN
	-- Create the SELECT statement which generates the "INSERT" output.
	
	SET @theExec = 'SELECT CONVERT(VARCHAR(8000), ''' + @newLine + 'INSERT INTO ' + @tableName + ' ' + @newLine
			+ @tab + '( ' + @theColumns + @newLine + @tab + ') ' + @sepInsertValue
			+ 'VALUES ' + @newLine
			+ @tab + '( '' + ' + @theSelect + ' + ''' + @newLine + @tab + ')' + @separator + ''') FROM ' + @tableName
END

IF (@theWhere != '' and @theWhere is not null) SET @theExec = @theExec + ' ' + @theWhere

IF (@skippedColumns = '') SET @skippedColumns = 'No columns were skipped.'

-- NOPE!
--SET @rowCount = EXEC ('SELECT COUNT(*) FROM ' + @tableName + ' ' + @theWhere)

--DDDDDDDD -- Debug Section -- DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

IF (@debugOn = 1)
BEGIN
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
END
--DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

IF (LEN(@theExec) = 8000)
BEGIN
	PRINT ''
	PRINT 'ERROR - You probably have exceeded the 8000 character limit of VARCHAR.'
	PRINT '        (Try to reduce the number of columns in your table - construct a view and then'
	PRINT '        start eliminating non-essential columns - or you can take a stab at modifying this'
	PRINT '        code.)  Good Luck!!'
	PRINT '        If you did not receive any errors below , then you actually hit the limit and did not'
	PRINT '        exceed it.  You really ARE lucky.  :D'
	PRINT ''
	PRINT ''
	PRINT ''
END

PRINT '----------------------------------------------------------------------------'
PRINT '-- SERVER:       ' + @@SERVERNAME
--PRINT '-- DATABASE:     ' + @@DBNAME
PRINT '-- TABLE:        ' + @tableName
PRINT '-- COLS SKIPPED: ' + @skippedColumns
PRINT '-- DATE:         ' + CONVERT(VARCHAR(13), getdate(), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), getdate(), @HH_MM_SS_mmm)
PRINT '-- USER:         ' + user_name()

IF (LEN(@theWhere) = 0 OR @theWhere = NULL)
	PRINT '-- RESTRICTIONS: NONE'
ELSE
	PRINT '-- RESTRICTIONS: ' + @theWhere

PRINT '-- '
PRINT '-- ** The following data was extracted using "Extract Data As Inserts.sql" by Parker Smart **'

IF (@wrapInTransaction = 1)
BEGIN
	PRINT ''
	PRINT 'BEGIN TRAN'
END

IF (@flushFirst = 1)
BEGIN
	PRINT ''
	IF (@theWhere != '' and @theWhere is not null)
		PRINT 'DELETE FROM ' + @tableName + ' ' + @theWhere
	ELSE
		PRINT 'DELETE FROM ' + @tableName
END

IF (@identityInsert = 1)
BEGIN
	PRINT ''
	PRINT 'SET IDENTITY_INSERT ' + @tableName + ' ON'
END

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
