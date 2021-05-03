SELECT
		  SCH.[name]		AS 'Schema'
		, TBL.[name]		AS 'Table'
		, COL.[name]		AS 'Column'
		, TYP.[name]		AS 'Type'
		, COL.max_length
		, COL.[precision]
		, COL.[scale]
		, COL.is_nullable
		--, COL.*

FROM	sys.tables		TBL

JOIN	sys.schemas		SCH
		ON	SCH.[schema_id] = TBL.[schema_id]
		AND	(SCH.[name]		= 'dbo' OR SCH.[name]		= 'HangFire')

JOIN	sys.columns		COL
		ON	COL.[object_id] = TBL.[object_id]

JOIN	sys.types		TYP
		ON	TYP.user_type_id	= COL.user_type_id

WHERE	COL.[name] LIKE '%company%'
--OR		COL.[name] LIKE '%name%'

ORDER BY SCH.[name], TBL.[name], COL.[name]

--SELECT * FROM sys.objects
--SELECT * FROM sys.columns
--SELECT * FROM sys.schemas
--SELECT * FROM sys.types