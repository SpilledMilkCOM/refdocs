DECLARE @execStatement	varchar(256)
DECLARE @startDate		DATETIME
DECLARE @endDate		DATETIME

SET @startDate = '1/1/2006'
SET @endDate = getdate()

DECLARE theCursor CURSOR FOR
SELECT 'SELECT CAST(COUNT(*) AS VARCHAR(40)) as [' + o.name + ' COUNT] FROM ' + o.name
			+ ' (NOLOCK) WHERE lst_updt_tmestmp BETWEEN ''' + CONVERT( VARCHAR(32), @startDate, 120) + ''''
												+ ' AND ''' + CONVERT( VARCHAR(32), @endDate, 120) + ''';'
FROM SYSOBJECTS o
JOIN SYSCOLUMNS c
	ON c.id = o.id
WHERE
		o.xtype = 'U'
--AND		(o.NAME LIKE 'WRK71T%' or o.name like 'fil__t%')
--AND		o.NAME = 'prt01t_participant'
AND		c.NAME = 'lst_updt_tmestmp'		-- Only do this on tables that have this column.
ORDER BY o.NAME

OPEN theCursor

FETCH NEXT FROM theCursor INTO @execStatement

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @execStatement
	EXEC (@execStatement)
	
	FETCH NEXT FROM theCursor INTO  @execStatement
END

CLOSE theCursor
DEALLOCATE theCursor