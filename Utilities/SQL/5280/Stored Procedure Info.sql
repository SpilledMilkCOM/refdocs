select so.name, sc.name, st.name
from 		sysobjects 	so
left outer join syscolumns 	sc
		on sc.id = so.id
left outer join	systypes	st
		on st.xtype = sc.xtype
where 
		so.type = 'P'
AND 		so.name like '%p_%'