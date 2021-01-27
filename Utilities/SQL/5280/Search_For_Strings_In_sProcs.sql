DECLARE @StringToSearch varchar(100) 

SET @StringToSearch = '%lonf_sel_ln_id_for_parti%'

SELECT 
	'sp_helptext ' + name

FROM (
SELECT DISTINCT TOP 100 PERCENT
	SO.name

FROM		sysobjects SO (NOLOCK)

INNER JOIN	syscomments SC (NOLOCK)
		ON	SO.id	= SC.ID
		AND SO.type = 'P'
		AND SC.text LIKE @stringtosearch
ORDER BY SO.Name
) tmp

GO