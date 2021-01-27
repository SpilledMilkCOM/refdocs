--=========================================================================================
-- Author:		Parker Smart
-- Date:		10/25/2003
-- History:		Modified on a whim to meet my needs.
--=========================================================================================
select
		  convert(varchar(32), o.name)	as 'Table'
		, convert(varchar(40), c.name)	as 'Colunn'
		, convert(varchar(16), t.name)	as 'Type'
		, c.length
from 			sysobjects o
inner join 		syscolumns c
	on o.id = c.id
inner join 		systypes t
	on c.xtype = t.xtype
--	and t.name in ('char', 'varchar')
where
o.name like 'nte34t_notetranmntryadj'
--		c.name like '%nbr%'
and		o.xtype = 'U'
order by o.name, c.colorder, c.name