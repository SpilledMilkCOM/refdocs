SELECT
--	'/* ' + CONVERT(CHAR(3), sc.colorder) + ' */		, ' + sc.name
--	  CONVERT(CHAR(35), so.name) as 'Table'
--	 '		, DEM.' + CONVERT(CHAR(70), sc.name) + 'AS ''dem_' + CONVERT(VARCHAR(70), sc.name) + '''' as "Column"
-- 	  '		, DEM.' + CONVERT(CHAR(40), sc.name) as "Column"
--	CONVERT(CHAR(32), sc.name) as 'nte30t_notepmtamthstry'
	  CONVERT(CHAR(40), so.name)					AS 'Table'
	, CONVERT(CHAR(40), sc.name)					AS 'Column'
--	, dbo.GetFirstToken(sc.name)
-- 	, dbo.GetRemainingTokens(sc.name)
-- 	, dbo.GetRemainingTokens(dbo.GetRemainingTokens(sc.name))
--	, dbo.AbbreviateColumnName(dbo.GetFirstToken(sc.name)) AS 'Abbrev'
-- 	, SC.COLORDER			AS "SEQ."
-- 	, CONVERT(CHAR(10), ST.NAME) AS "TYPE"
-- 	, SC.LENGTH AS "SIZE"
-- 	, (SELECT SUM(SC2.LENGTH) FROM SYSCOLUMNS SC2 WHERE SC2.ID = SC.ID)
-- 	AS "ROW SIZE"
FROM 	sysobjects so

INNER JOIN syscolumns sc
	ON 	sc.id = so.id
	AND	sc.name like '%ln_id%'		-- List all columns across all tables.
INNER JOIN systypes st
	ON	st.xtype = sc.xtype
WHERE	
		so.xtype in ('U', 'V')
--and		so.name = 'wrk71t_chela_mast'
--and		(sc.colorder = 1 OR (sc.colorder BETWEEN 1 AND 255))
--and		(sc.colorder = 1 OR (sc.colorder BETWEEN 256 AND 512))
--and		(sc.colorder = 1 OR (sc.colorder BETWEEN 513 AND 768))
--and		(sc.colorder = 1 OR (sc.colorder BETWEEN 767 AND 1022))

ORDER BY so.name, sc.colorder