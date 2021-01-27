-- REF: https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html

SELECT
		  TBL.TABLE_NAME
		, COL.COLUMN_NAME
        , COL.COLUMN_TYPE
        , COL.ORDINAL_POSITION
        
FROM 	information_schema.tables		AS TBL

JOIN	information_schema.columns		AS COL
		ON	COL.TABLE_NAME		= TBL.TABLE_NAME
        AND	COL.TABLE_SCHEMA	= TBL.TABLE_SCHEMA

WHERE	TBL.TABLE_TYPE			= 'BASE TABLE'
AND		TBL.TABLE_SCHEMA		= 'aa'

AND		(COL.COLUMN_NAME LIKE '%Industry%'
	OR	TBL.TABLE_NAME LIKE '%Industry%')

ORDER BY TBL.TABLE_NAME, COL.COLUMN_NAME;