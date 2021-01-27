/* Fix Identity numbering... */
/* NOTE:
	1) Currently fixing table (use Find & Replace to change):
		ffl04t_recd_info
	2) Update the column list.
*/

IF (exists (select * from sysobjects where id = object_id(N'[dbo].[temp_Identity]') and OBJECTPROPERTY(id, N'IsTable') = 1))
BEGIN
	drop table [dbo].[temp_Identity]
END

IF (exists (select * from sysobjects where id = object_id(N'[dbo].[temp_IdentitySource]') and OBJECTPROPERTY(id, N'IsTable') = 1))
BEGIN
	drop table [dbo].[temp_IdentitySource]
END

SELECT * INTO temp_IdentitySource
FROM ffl04t_recd_info		--<<<<<< Table to fix. (Back it up first)

SELECT IDENTITY(INT, 1, 1) AS new_ident_id
	, recd_type_id	--<<<< Skip the old ID column and start with the rest.
	, source_name
	, column_name
	, column_start
	, column_length
	, column_format
	, column_data_type_id
	, column_nbr
	, default_value
INTO temp_Identity
FROM ffl04t_recd_info		--<<<<<< Table to fix.
ORDER BY recd_info_id		--Keep the IDs in the same order.

DELETE FROM ffl04t_recd_info	--Flush out the old records.  They should be backed up in temp_IdentitySource.

SET IDENTITY_INSERT ffl04t_recd_info ON

INSERT INTO ffl04t_recd_info
	( recd_info_id	--<<<< Ignore the comment below because here's the old ID.
	, recd_type_id	--<<<< Skip the old ID column and start with the rest.
	, source_name
	, column_name
	, column_start
	, column_length
	, column_format
	, column_data_type_id
	, column_nbr
	, default_value
	)
SELECT new_ident_id	--<<<< This is the same
	, recd_type_id	--<<<< Skip the old ID column and start with the rest.
	, source_name
	, column_name
	, column_start
	, column_length
	, column_format
	, column_data_type_id
	, column_nbr
	, default_value
FROM temp_Identity

SET IDENTITY_INSERT ffl04t_recd_info OFF

/*
IF (exists (select * from sysobjects where id = object_id(N'[dbo].[temp_Identity]') and OBJECTPROPERTY(id, N'IsTable') = 1))
BEGIN
	drop table [dbo].[temp_Identity]
END
*/