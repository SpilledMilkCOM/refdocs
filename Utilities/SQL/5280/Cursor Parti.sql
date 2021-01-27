-- exec dbo.lndp_sel_NSF_fee 11, '1/1/2000'
DECLARE @partiID	INT

DECLARE theCursor CURSOR FOR
select note_id from nte01t_note
order by note_id

OPEN theCursor

FETCH NEXT FROM theCursor INTO @partiID

WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @partiID
	exec dbo.lndp_sel_NSF_fee @partiID, '1/1/2003'
	FETCH NEXT FROM theCursor INTO @partiID
END

CLOSE theCursor
DEALLOCATE theCursor