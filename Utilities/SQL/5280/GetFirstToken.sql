if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetFirstToken]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GetFirstToken]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[GetFirstToken] (
			  @pTokens					VARCHAR(128)
)
RETURNS VARCHAR(128) AS
--RETURNS INT AS  
BEGIN
DECLARE	@result 		AS VARCHAR(128)
DECLARE @pos			AS INT

	IF (@pTokens <> '')
	BEGIN
		SET @pTokens = REPLACE(@pTokens, '_', ' ')
	
		SET @pos = CHARINDEX(' ', @pTokens)
	
		IF (@pos > 0)
			SET @result = LEFT(@pTokens, @pos)
		ELSE
			SET @result = @pTokens
	END

	RETURN @result
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
