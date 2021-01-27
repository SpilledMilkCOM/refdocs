DECLARE @execStatement	varchar(256)

DECLARE theCursor CURSOR FOR
SELECT 'SELECT CAST(COUNT(lst_updt_tmestmp) AS VARCHAR(40)) as [' + o.name + ' COUNT], CAST(MIN(lst_updt_tmestmp) AS VARCHAR(20)) as OLDEST, CAST(MAX(lst_updt_tmestmp) AS VARCHAR(20)) as YOUNGEST FROM ' + o.name + ' (nolock);'
FROM SYSOBJECTS o
JOIN SYSCOLUMNS c
	ON c.id = o.id
WHERE
		o.xtype = 'U'
--AND		(o.NAME LIKE 'WRK71T%' or o.name like 'fil__t%')
AND		c.NAME = 'lst_updt_tmestmp'		-- Only do this on tables that have this column.
ORDER BY o.NAME

OPEN theCursor

FETCH NEXT FROM theCursor INTO @execStatement

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--PRINT @execStatement
	EXEC (@execStatement)
	
	FETCH NEXT FROM theCursor INTO  @execStatement
END

CLOSE theCursor
DEALLOCATE theCursor