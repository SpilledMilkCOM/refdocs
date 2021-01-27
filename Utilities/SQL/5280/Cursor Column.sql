/*
Author:		Parker Smart
Date:		7/23/2004

Purpose: This script will find all of the tables that have a lst_updt_userid column
			and then select on that table to restrict that column to a value ('NLCNV2').
			
NOTE: This could easily by modified to look for eff_dt and restrict on a date.  Or you could
		look for multiple columns, but possibly restrict on only one of those columns.
*/
DECLARE @tableName	varchar(64)
DECLARE @columnName varchar(64)

DECLARE theCursor CURSOR FOR
select so.name, sc.name
from sysobjects so
join syscolumns sc
	on sc.id = so.id
where sc.name = 'lst_updt_userid'
order by so.name

OPEN theCursor

FETCH NEXT FROM theCursor INTO @tableName, @columnName

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @tableName
	EXEC ('SELECT * FROM ' + @tableName + ' WHERE lst_updt_userid = ''NLCNV2''')
	
	FETCH NEXT FROM theCursor INTO @tableName, @columnName
END

CLOSE theCursor
DEALLOCATE theCursor