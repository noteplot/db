set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20170716
-- Description:	Процедура получения списка типов значений
-- только для числовых типов
-- =============================================

IF OBJECT_ID('[dbo].[ParamValueTypesGet]', 'P') is null
 EXEC('create procedure [dbo].[ParamValueTypesGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParamValueTypesGet
@IsNumeric BIT = 1 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ParamValueTypeID,
		ParamValueTypeCode,
		ParamValueTypeShortName,				
		ParamValueTypeName,
		[IsNumeric],
		[Scale],
		[Precision]
	FROM dbo.ParamValueTypes
	WHERE [IsNumeric] = IsNull(@IsNumeric,[IsNumeric])
END
GO
