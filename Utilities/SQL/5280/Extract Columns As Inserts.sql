DECLARE @dbName		VARCHAR(255)
DECLARE @columnTable	VARCHAR(255)

SET @columnTable = 'column_desc'

SET @dbName = 'spstrd00_star'

SELECT
	'INSERT INTO ' + @columnTable + ' (db_name, table_name, column_name, column_desc) '
	+ 'VALUES (''' + @dbName + ''''
	+ ', ''' + RTRIM(so.name) + ''''
	+ ', ''' + RTRIM(sc.name) + ''', NULL)'
FROM 	sysobjects so
INNER JOIN syscolumns sc
	ON 	sc.id = so.id
INNER JOIN systypes st
	ON	st.xtype = sc.xtype
WHERE	
	so.xtype in ('U', 'V')
AND	so.name in (
  'fil01t_input_file_tracking' 
, 'fil02t_input_file_tracking_detail' 
, 'fil03t_fileid' 
, 'fil04t_mini' 
, 'fil05t_minierr' 
, 'fil11t_filebase' 
, 'fil12t_tblebase' 
, 'fil13t_loadfile' 
, 'fil14t_coldatatype' 
, 'fil15t_recdinfo' 
, 'fil16t_filetbleassocn' 
, 'fil24t_sdrtncont' 
, 'fil24t_sdrtndtl' 
, 'fil24t_sdrtnhdr' 
, 'fil24t_sdrtntrlr' 
, 'fil25t_sdvalidtnaccptd' 
, 'fil25t_sdvalidtnhdr' 
, 'fil25t_sdvalidtninputttl' 
, 'fil25t_sdvalidtninputttlcont' 
, 'fil25t_sdvalidtninputttlcont2' 
, 'fil25t_sdvalidtnpmtdtl' 
, 'fil25t_sdvalidtnpmtdtlcont' 
, 'fil25t_sdvalidtnpmtdtlcont2' 
, 'fil25t_sdvalidtntrlr' 
, 'fil26t_tdrtndtl' 
, 'fil26t_tdrtnhdr' 
, 'fil26t_tdrtntrlr' 
, 'fil27t_tdvalidtndtl' 
, 'fil27t_tdvalidtnhdr' 
, 'fil27t_tdvalidtntrlr' 
)

ORDER BY so.name, sc.colorder --, sc.name

