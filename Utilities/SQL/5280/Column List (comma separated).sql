SELECT
	', ' + CONVERT(VARCHAR(30), sc.name)
FROM 	sysobjects so
INNER JOIN syscolumns sc
	ON 	sc.id = so.id
INNER JOIN systypes st
	ON	st.xtype = sc.xtype
WHERE	
--		(so.name like 'wrk70%'		-- List Table
--		or so.name like 'wrk80%')	-- List Table
		so.xtype in ('U', 'V')
	AND	so.name in ('bat01t_excpmessage')
ORDER BY sc.colorder