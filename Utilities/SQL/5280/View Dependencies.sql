select *
from
	(select distinct
		convert(char(40), so.name) AS "Name"
	--	, so.id
	--	, sd.depid
	
		, (select convert(char(40), so2.name)
			from sysobjects so2
			where so2.id = sd.depid
		) as 'Depends On'
	--	, selall 	'In Select'
	--	, resultobj 	'Being Updated'
	--	, readobj	'Being Read'
	
	from sysobjects 	so
	left join sysdepends 	sd
		on so.id = sd.id
	) dt
where dt.name like 'utl08%'				-- <<<<<< Adjust this to filter
/*and resultobj=1*/
order by dt.name, dt.[Depends On]

