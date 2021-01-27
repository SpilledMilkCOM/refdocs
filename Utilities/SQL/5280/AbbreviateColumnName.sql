if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AbbreviateColumnName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[AbbreviateColumnName]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[AbbreviateColumnName] (
			  @pColumnName					SYSNAME
)
RETURNS SYSNAME AS
--RETURNS INT AS  
BEGIN
DECLARE	@result 		AS SYSNAME
DECLARE @abbrev			AS VARCHAR(128)
DECLARE @colName		AS VARCHAR(128)
DECLARE @colToken		AS VARCHAR(128)

--	SET @result = @pColumnName

	SET @abbrev = (SELECT abbreviation FROM utl99t_abbrev WHERE [description] = @pColumnName)

	IF (@abbrev IS NOT NULL)
	BEGIN
	-- Look for an exact match.
		SET @result = @abbrev
	END
	ELSE
	BEGIN
	-- Look for each word to see if we can abbreviate it.
		SET @colName	= @pColumnName
		SET @colToken	= dbo.GetFirstToken(@colName)
--		SET @colName	= dbo.GetRemainingTokens(@colName)

		SET @result = @colToken

-- 		WHILE (@colToken <> '')
-- 		BEGIN
-- 			SET @abbrev = (SELECT abbreviation FROM utl99t_abbrev WHERE [description] = @colToken)
-- 
-- 			IF (@result <> '')
-- 				SET @result = @result + '_'
-- 
-- 			IF (@abbrev IS NOT NULL)
-- 				SET @result = @result + @abbrev
-- 			ELSE
-- 				SET @result = @result + @colToken
-- 
-- 			SET @colToken	= dbo.GetFirstToken(@colName)
-- 			SET @colName	= dbo.GetRemainingTokens(@colName)
-- 		END
	END

--	RETURN LOWER(@result)
	RETURN @result
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
