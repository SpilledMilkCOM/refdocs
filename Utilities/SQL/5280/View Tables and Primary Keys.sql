select		  convert(varchar(32), so.name) As 'Table'
			, convert(varchar(32), so2.name) AS 'Constraint'
from 		sysobjects so
inner join	sysconstraints st
			on so.id = st.id
inner join	sysobjects so2
			on so2.id = st.constid
where 		so.xtype = 'U'
and 		so.name like '%profile%'

order by so.name