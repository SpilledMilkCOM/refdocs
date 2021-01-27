--USE CTD
--USE Enterprise;
--USE Media;			-- AdProjectLog
--USE mentusnet;		-- DCS!
--USE NCM_DataWarehouse
--USE rain;
USE Media;

SELECT
		  SCH.[name]		AS 'Schema'
		, OBJ.[name]		AS 'Table'
		, COL.[name]		AS 'Column'
		, TYP.[name]		AS 'Type'
		--, COL.max_length
		--, COL.[precision]
		--, COL.[scale]
		--, COL.is_nullable
		--, COL.*
FROM	sys.objects		OBJ
JOIN	sys.schemas		SCH
		ON	SCH.[schema_id] = OBJ.[schema_id]
		AND	(SCH.[name]		= 'dbo' OR SCH.[name]		= 'aam')
JOIN	sys.columns		COL
		ON	COL.[object_id] = OBJ.[object_id]
JOIN	sys.types		TYP
		ON	TYP.user_type_id	= COL.user_type_id

WHERE	OBJ.[type_desc] = 'USER_TABLE'
--AND		TYP.[name] LIKE '%NVARCHAR%'
--AND		COL.[name] LIKE '%%'

AND		COL.[name] LIKE '%JobNumber%'
--		OR OBJ.[name] LIKE '%schedule%')
--AND		OBJ.[name] = 'AdProjectLog'

ORDER BY OBJ.[name], COL.[name]

--SELECT * FROM sys.objects
--SELECT * FROM sys.columns
--SELECT * FROM sys.schemas
--SELECT * FROM sys.types