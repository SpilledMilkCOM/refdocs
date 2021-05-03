-- Explore Database

-- REF: https://docs.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/system-compatibility-views-transact-sql?view=sql-server-ver15

-- All of the schemas

SELECT
		*
FROM	sys.schemas
WHERE	[schema_id] < 255

-- All of the schemas you care about

SELECT
		*
FROM	sys.schemas
WHERE	[schema_id] < 255
AND		[name] NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')

-- All of the tables you care about

SELECT
		  SSC.[name]					AS 'Schema'
		, STB.[name]					AS 'Table'
		, STB.*

FROM	sys.tables						STB

JOIN	sys.schemas						SSC
		ON	SSC.[schema_id]			= STB.[schema_id]

WHERE	SSC.[schema_id] < 255
AND		SSC.[name] NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')
ORDER BY	SSC.[name], STB.[name]