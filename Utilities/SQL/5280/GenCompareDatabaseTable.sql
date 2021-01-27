--========================================================================================
-- Author:        Parker Smart
-- Date:          10/16/2004
--
-- Description:   Generates row compares the 'same' tables in different databases.
-- 
--========================================================================================

DECLARE @tabChar 		AS VARCHAR(1)

DECLARE @dbSrc1			AS VARCHAR(64)
DECLARE @dbSrc2			AS VARCHAR(64)
DECLARE @noLock1		AS VARCHAR(16)
DECLARE @noLock2		AS VARCHAR(16)
DECLARE @tableName		AS VARCHAR(64)
DECLARE @columnName 	AS CHAR(32)
DECLARE @columnOrder	AS INTEGER
DECLARE	@lstUpdtTmestmp	DATETIME
DECLARE @mm_dd_yyyy		INT
DECLARE @HH_MM_SS_mmm	INT

SET @mm_dd_yyyy				= 101
SET @HH_MM_SS_mmm			= 14

SET @lstUpdtTmestmp = '11/02/2004'

SET @dbSrc1		= 'spstrp00_star'		-- Keep for reference.
SET @dbSrc1		= 'spstrm00_star'		-- Last one wins.
SET @noLock1	= '(NOLOCK)'

SET @dbSrc2		= 'spstrp00_starrpt'
SET @dbSrc2		= '[5280-CANSQL-02].spstrm00_star_age.dbo'
SET @noLock2	= '(NOLOCK)'
SET @noLock2	= '/*(NOLOCK)*/'		-- Generate this as a comment to show that "Hey, we're not locking here."

SET @tableName	= 'nte19t_notetrandisb'
SET @tabChar 	= '	'

PRINT '--========================================================================================'
PRINT '-- Author:        Parker Smart'
PRINT '-- Generated on:  ' + CONVERT(VARCHAR(13), GETDATE(), @mm_dd_yyyy) + ' ' + CONVERT(VARCHAR(13), GETDATE(), @HH_MM_SS_mmm) 
PRINT '--'
PRINT '-- NET DB (1):   ' + @dbSrc1
PRINT '-- VB6 DB (2):   ' + @dbSrc2
PRINT '-- Compare Table: ' + @tableName
--PRINT '--     where lst_updt_tmestmp >= ' + cast(@lstUpdtTmestmp as varchar(32))
PRINT '--========================================================================================'
PRINT ''

PRINT 'SET ANSI_NULLS		ON		-- This secontion is needed to handle requests between servers.'
PRINT 'SET ANSI_WARNINGS	ON'
PRINT 'GO'
PRINT ''

PRINT 'DECLARE		@lstUpdtTmestmp		DATETIME'
PRINT 'DECLARE		@tableName			VARCHAR(64)'
PRINT ''

PRINT 'SET @lstUpdtTmestmp = ''' + CONVERT(VARCHAR(13), @lstUpdtTmestmp, @mm_dd_yyyy) + ''''
PRINT 'SET @tableName		= ''' + @tableName + ''''
PRINT ''

PRINT 'PRINT ''====== Comparison of ' + @dbSrc1 + '..'' + @tableName + '' to ' + @dbSrc2 + '.'' + @tableName + '' ======'''
PRINT 'PRINT ''       where lst_updt_tmestmp >= ' + CONVERT(VARCHAR(13), @lstUpdtTmestmp, @mm_dd_yyyy) + ''''
PRINT 'PRINT '''''
PRINT 'PRINT ''Column(s) NOT being compared in the FULL OUTER JOIN statement:'''
PRINT 'PRINT ''		<<NONE>>		(lst_updt_tmestmp, lst_updt_userid)'''
PRINT 'PRINT '''''
PRINT 'PRINT ''Compare Date:'' + CONVERT(VARCHAR(32), CONVERT(datetime, getdate()))'
PRINT ''
PRINT ' -- View header immediately...'
PRINT 'GO'
PRINT ''

PRINT 'DECLARE @lstUpdtTmestmp		DATETIME'
PRINT 'DECLARE @rowCount1			INTEGER'
PRINT 'DECLARE @rowCount2			INTEGER'
PRINT 'DECLARE @tableName			VARCHAR(64)'
PRINT ''
PRINT 'SET @lstUpdtTmestmp = ''' + CONVERT(VARCHAR(13), @lstUpdtTmestmp, @mm_dd_yyyy) + ''''
PRINT 'SET @tableName		= ''' + @tableName + ''''
PRINT ''

PRINT 'PRINT '''''
PRINT 'SET @rowCount1 = (SELECT COUNT(*) FROM ' + @dbSrc1 + '..' + @tableName + ' ' + @noLock1 + ' WHERE lst_updt_tmestmp >= @lstUpdtTmestmp)'
PRINT ''
PRINT 'PRINT ''' + @dbSrc1 + '..' + @tableName + ': '' + CAST(@rowCount1 AS VARCHAR(16))'
PRINT ''
PRINT 'SET @rowCount2 = (SELECT COUNT(*) FROM ' + @dbSrc2 + '.' + @tableName + ' ' + @noLock2 + ' WHERE lst_updt_tmestmp >= @lstUpdtTmestmp)'
PRINT ''
PRINT 'PRINT ''' + @dbSrc2 + '.' + @tableName + ': '' + CAST(@rowCount2 AS VARCHAR(16)) + ''     ('' + CAST(@rowCount2 - @rowCount1 AS VARCHAR(16)) + '')'''
PRINT ''
PRINT 'PRINT '''''
PRINT ''
PRINT '-- It would be nice to see SOME results right away.'
PRINT 'GO'

PRINT 'DECLARE @lstUpdtTmestmp		DATETIME'
PRINT 'SET @lstUpdtTmestmp = ''' + CONVERT(VARCHAR(13), @lstUpdtTmestmp, @mm_dd_yyyy) + ''''
PRINT ''

PRINT 'SELECT'
PRINT @tabChar + '  ISNULL(db1                                 , db2                                 ) AS db'

DECLARE theCursor CURSOR FOR
select so.name, sc.name
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where so.name = @tableName
order by so.name

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @tabChar + ', ISNULL(db1_' + @columnName + ', db2_' + @columnName + ') AS ' + @columnName
	
	FETCH NEXT FROM theCursor INTO @tableName, @columnName
END

CLOSE theCursor
DEALLOCATE theCursor

PRINT 	'FROM'
PRINT 	'('
PRINT 	'SELECT'
PRINT 	@tabChar + '''NET''                              AS db1'

DECLARE theCursor CURSOR FOR
select so.name, sc.name
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where so.name = @tableName
order by so.name

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @tabChar + ', ' + @columnName + ' AS db1_' + @columnName
	
	FETCH NEXT FROM theCursor INTO @tableName, @columnName
END

CLOSE theCursor
DEALLOCATE theCursor

PRINT 'FROM' + @tabChar + @dbSrc1 + '..' + @tableName + ' ' + @noLock1
PRINT 'WHERE lst_updt_tmestmp >= @lstUpdtTmestmp'
PRINT ') AS source1'
PRINT 'FULL OUTER JOIN'
PRINT '('
PRINT 'SELECT'
PRINT 	@tabChar + '''VB6''                              AS db2'

DECLARE theCursor CURSOR FOR
select so.name, sc.name
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where so.name = @tableName
order by sc.colorder

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @tabChar + ', ' + @columnName + ' AS db2_' + @columnName
	
	FETCH NEXT FROM theCursor INTO @tableName, @columnName
END

CLOSE theCursor
DEALLOCATE theCursor

PRINT 'FROM' + @tabChar + @dbSrc2 + '.' + @tableName + ' ' + @noLock2
PRINT 'WHERE lst_updt_tmestmp >= @lstUpdtTmestmp'
PRINT ') AS source2'


DECLARE theCursor CURSOR FOR
select so.name, sc.name, sc.colorder
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where so.name = @tableName
order by sc.colorder

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName, @columnOrder

WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF (@columnName <> 'lst_updt_userid' AND @columnName <> 'lst_updt_tmestmp')
	BEGIN
		IF (@columnOrder = 1)
			PRINT @tabChar + 'ON  (db1_' + @columnName + ' = db2_' + @columnName
		ELSE
			PRINT @tabChar + 'AND (db1_' + @columnName + ' = db2_' + @columnName
	
		PRINT @tabChar + @tabChar + 'OR (db1_' + RTRIM(@columnName) + ' IS NULL'
		PRINT @tabChar + @tabChar + @tabChar + 'AND db2_' + RTRIM(@columnName) + ' IS NULL))'
	END

	FETCH NEXT FROM theCursor INTO @tableName, @columnName, @columnOrder
END

CLOSE theCursor
DEALLOCATE theCursor

PRINT 'WHERE'
PRINT @tabChar + '   db1 IS NULL'
PRINT @tabChar + 'OR db2 IS NULL'
PRINT 'ORDER BY'

DECLARE theCursor CURSOR FOR
select so.name, sc.name, sc.colorder
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where so.name = @tableName
order by sc.colorder

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName, @columnOrder

WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF (@columnName <> 'lst_updt_userid' AND @columnName <> 'lst_updt_tmestmp')
	BEGIN
		IF (@columnOrder = 1)
			PRINT @tabChar + '  ' + @columnName
		ELSE
			PRINT @tabChar + ', ' + @columnName
	END

	FETCH NEXT FROM theCursor INTO @tableName, @columnName, @columnOrder
END

CLOSE theCursor
DEALLOCATE theCursor