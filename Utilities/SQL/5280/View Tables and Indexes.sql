SELECT
	  CAST(so.name AS CHAR(32))	AS 'TableName'
	, CAST(so2.name AS CHAR(32))	AS 'KeyName'
--	, CAST(sc.name AS CHAR(32))	AS 'ColumnName'
	, sk.*
FROM
		sysobjects 		so
INNER JOIN 	sysobjects 		so2
		ON so.id = so2.parent_obj
INNER JOIN	sysindexes		sk
		ON sk.id = so.id
/*
INNER JOIN	syscolumns		sc
		ON sc.id = so.id
*/
WHERE     so2.xtype = 'PK'
order by so.name, so2.name