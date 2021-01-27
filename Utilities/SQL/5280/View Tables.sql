-- select 'sp_changeobjectowner	' + cast (name as varchar(32)) + ', dbo
-- GO'
--select 'TRUNCATE TABLE ' + cast (name as varchar(32))
--select 'DELETE FROM ' + cast (name as varchar(32))
--select 'select count(*) as ''count of ' + name + ''' from ' + cast (name as varchar(32)) + ' (nolock)'
--select '	, ''' + cast (name as varchar(32)) + ''''
select name
from sysobjects so
where xtype = 'U'
and (SO.[name]			LIKE 'act__t%'
OR		SO.[name]		LIKE 'bat__t%'
OR		SO.[name]		LIKE 'cde__t%'
OR		SO.[name]		LIKE 'cnt__t%'
OR		SO.[name]		LIKE 'con__t%'
OR		SO.[name]		LIKE 'fil__t%'
OR		SO.[name]		LIKE 'fof__t%'
OR		SO.[name]		LIKE 'fun__t%'
OR		SO.[name]		LIKE 'loan__t%'
OR		SO.[name]		LIKE 'nte__t%'
OR		SO.[name]		LIKE 'prc__t%'
OR		SO.[name]		LIKE 'prt__t%'
OR		SO.[name]		LIKE 'pur__t%'
OR		SO.[name]		LIKE 'src__t%'
OR		SO.[name]		LIKE 'svc__t%'
OR		SO.[name]		LIKE 'trn__t%'
OR		SO.[name]		LIKE 'wrk__t%'
OR		SO.[name]		LIKE 'xmt__t%')
--and name like 'nte[0-9]%' or name like 'prt[0-9]%'
order by name