-- =============================================
-- Author:		[ab]
-- Create date: 20170716
-- Description:	Процедура получения списка типов значений
-- =============================================

IF OBJECT_ID('[dbo].[ParamValueTypesGet]', 'P') is null
 EXEC('create procedure [dbo].[ParamValueTypesGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParamValueTypesGet 
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
END
GO
