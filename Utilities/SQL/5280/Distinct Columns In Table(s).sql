SET NOCOUNT ON

DECLARE	@tableName		AS VARCHAR(32)
SET		@tableName		= 'wrk70t_rbcnv_intmast'

DECLARE	@fileBaseName	AS VARCHAR(32)
SET		@fileBaseName	= 'intmast'

DECLARE @newLine		AS CHAR(1)
SET		@newLine		= '
'

DECLARE @tab		AS CHAR(1)
SET		@tab		= '	'

PRINT '-------------------------------------------------------------------------------------------------------------'
PRINT '-- Author       : Parker Smart'
PRINT '-- Generated By : ' + user
PRINT '-- Date         : ' + CONVERT(VARCHAR(32), getdate())
PRINT '-- Table        : ' + @tableName
PRINT '-- Description  : This SQL script displays the the value counts in each column (except NULL counts).'
PRINT '-------------------------------------------------------------------------------------------------------------'

SELECT
	 'SELECT ' + CONVERT(VARCHAR(40), sc.name) + ' AS ''' + FIL15.srce_name + '''' + @newLine
		+ @tab + ', COUNT(' + CONVERT(VARCHAR(40), sc.name) + ') AS ''COUNT(' + @tableName + '.' + CONVERT(VARCHAR(40), sc.name) + ')''' + @newLine
		+ 'FROM' + @tab + @tab + @tableName + @newLine
		+ 'WHERE' 		+ @tab + @tab + CONVERT(VARCHAR(40), sc.name) + ' IS NOT NULL' + @newLine
		+ 'GROUP BY' 	+ @tab + CONVERT(VARCHAR(40), sc.name) + @newLine
		+ 'ORDER BY' 	+ @tab + CONVERT(VARCHAR(40), sc.name) + @newLine + @newLine
FROM 		sysobjects so
INNER JOIN 	syscolumns sc
			ON 	sc.id = so.id
INNER JOIN 	systypes st
			ON	st.xtype = sc.xtype
INNER JOIN	fil15t_recdinfo				FIL15
			ON FIL15.[col_name] 		= sc.name
INNER JOIN	fil16t_filetbleassocn		FIL16
			ON FIL16.recd_type_id		= FIL15.recd_type_id
INNER JOIN	fil12t_tblebase				FIL12
			ON 	FIL12.tble_base_id		= FIL16.tble_base_id
			AND FIL12.tble_base_name	= @tableName
INNER JOIN	fil11t_filebase				FIL11
			ON 	FIL11.file_base_id		= FIL16.file_base_id
			AND FIL11.file_base_name 	= @fileBaseName

WHERE	
		so.xtype in ('U', 'V')
and		so.name = @tableName
and		sc.name NOT IN (
						  'line_nbr'
						, 'account_loan_number'
						, 'accumulated_outstanding_balance_amount'
						, 'accrued_interest'
						, 'risk_premium_balance'
						, 'issue_date'
						, 'original_proceeds'
						, 'payment_due_date'
						, 'regular_payment_amount'
						, 'last_interest_calculation_date'
						, 'interest_collected'
						, 'interest_earned'
						, 'outstanding_balance'
						, 'lst_updt_tmestmp'
						, 'lst_updt_userid'
						)

ORDER BY so.name, sc.colorder, sc.name --, sc.name