declare @dbSource	varchar(16)
declare @dbDest		varchar(16)
declare @sqlStatement	varchar(256)
declare @theCount	int

set @dbSource	= 'sbx_nb'		-- Search and replace (CTRL-H) the source to really change these.
set @dbDest	= 'cstarp00_star'	-- Search and replace (CTRL-H) the source to really change these.

print 'DATABASE DIFFERENCES:'
print 'Source:       ' + @dbSource
print 'Destination:  ' + @dbDest
print ''
print ''

--==========================================================================================================================
-- Select the tables that were in SOURCE and NOT found in DEST

set @theCount = (select count(so1.name) from sbx_nb.dbo.sysobjects so1 where so1.xtype = 'U' and so1.name not in 
			(select so2.name from cstarp00_star.dbo.sysobjects so2 where so2.xtype = 'U'))

if (@theCount <> 0) begin
	print 'Tables DELETED in ' + @dbSource
	
	-- Select the tables that were in SOURCE and NOT found in DEST
	select convert(char(30), so1.name) from sbx_nb.dbo.sysobjects so1
	where so1.xtype = 'U'
		and so1.name not in (select so2.name from cstarp00_star.dbo.sysobjects so2 where so2.xtype = 'U')
	order by so1.name
end
else begin
	print 'NO tables were deleted in ' + @dbSource
end

print ''

--==========================================================================================================================
-- Select the tables that are in DEST and NOT found in SOURCE

set @theCount = (select count(so1.name) from cstarp00_star.dbo.sysobjects so1
	where so1.xtype = 'U'
		and so1.name not in (select so2.name from sbx_nb.dbo.sysobjects so2 where so2.xtype = 'U')
	)

if (@theCount <> 0) begin
	
	print 'Tables ADDED to ' + @dbDest
	
	-- Select the tables that ARE in DEST and NOT found in SOURCE
	select convert(char(30), so1.name) from cstarp00_star.dbo.sysobjects so1
	where so1.xtype = 'U'
		and so1.name not in (select so2.name from sbx_nb.dbo.sysobjects so2 where so2.xtype = 'U')
	order by so1.name
end
else begin
	print 'NO tables were added to ' + @dbDest
end

--==========================================================================================================================
-- Look for deleted columns in tables of the same name.

print 'Columns DELETED from ' + @dbDest
	
select convert(char(30), so1.name), convert(char(30), sc1.name) from sbx_nb.dbo.sysobjects so1, sbx_nb.dbo.syscolumns sc1, cstarp00_star.dbo.sysobjects so2
	where so1.id = sc1.id
	and so1.name = so2.name
	and so1.xtype = 'U'
	and sc1.name not in (select sc3.name from cstarp00_star.dbo.sysobjects so3, cstarp00_star.dbo.syscolumns sc3
				where so2.name = so3.name
				and so3.id = sc3.id
				and so3.xtype = 'U')

--==========================================================================================================================
-- Look for deleted columns in tables of the same name.

print 'Columns ADDED to ' + @dbDest

select convert(char(30), so1.name), convert(char(30), sc2.name) from sbx_nb.dbo.sysobjects so1, cstarp00_star.dbo.syscolumns sc2, cstarp00_star.dbo.sysobjects so2
	where so2.id = sc2.id
	and so1.name = so2.name
	and so1.xtype = 'U'
	and sc2.name not in (select sc3.name from sbx_nb.dbo.sysobjects so3, sbx_nb.dbo.syscolumns sc3
				where so2.name = so3.name
				and so3.id = sc3.id
				and so3.xtype = 'U')

