select *
from
	(select distinct
		(select convert(char(40), so2.name)
			from sysobjects so2
			where so2.id = sd.depid
			and so2.name like 'utl08%'	-- <<<<<< Adjust this to filter the names.
		) as "Name"
		, convert(char(40), so.name) AS "Used By"
	--	, so.id
	--	, sd.depid
	--	, selall 	'In Select'
	--	, resultobj 	'Being Updated'
	--	, readobj	'Being Read'
	
	from sysobjects 	so
	left join sysdepends 	sd
		on so.id = sd.id
	) dt
where dt.name is not null
/*and resultobj=1*/
order by dt.name, dt.[Used By]

