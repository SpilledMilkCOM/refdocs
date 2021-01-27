/* This will break out the counts by "last update day"
*/

SELECT COUNT(*)
FROM nte40t_noteactlog
GO

select
	  lst_updt_tmestmp
	, count(lst_updt_tmestmp) AS "Count"
from
	(
	select
		CONVERT(DATETIME,
		CONVERT(VARCHAR, DATEPART(mm, lst_updt_tmestmp))
		+ '/'
		+ CONVERT(VARCHAR, DATEPART(dd, lst_updt_tmestmp))
		+ '/'
		+ CONVERT(VARCHAR, DATEPART(yy, lst_updt_tmestmp))) AS lst_updt_tmestmp
	from nte40t_noteactlog
	--where lst_updt_tmestmp > '4/6/2004'
	) ttt
group by lst_updt_tmestmp
order by lst_updt_tmestmp