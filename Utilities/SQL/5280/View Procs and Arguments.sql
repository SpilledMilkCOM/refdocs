SELECT
	  CONVERT(CHAR(35), so.name) 	as "Table"
	, CONVERT(CHAR(30), sc.name) 	as "Column"
	, sc.colorder			as "Seq."
	, CONVERT(CHAR(10), st.name) 	as "Type"
	, sc.length 			as "Size"
	, (SELECT count(*) 	FROM syscolumns sc3 WHERE sc3.id = sc.id)
	as "Arg(s)"
	, (SELECT sum(sc2.length) FROM syscolumns sc2 WHERE sc2.id = sc.id)
	as "Total Size"
FROM 	sysobjects so
INNER JOIN syscolumns sc
	ON 	sc.id = so.id
--	AND	sc.name like '%name%'		-- List all arguments across all tables.
INNER JOIN systypes st
	ON	st.xtype = sc.xtype
WHERE	
		so.xtype in ('P')
AND		so.name not like 'dt_%'		-- 5280 Naming convention
--		so.name = 'prt06t_partiemail'
--		or so.name like 'wrk80%')	-- List Table


ORDER BY so.name, sc.colorder --, sc.name

