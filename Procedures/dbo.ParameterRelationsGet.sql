-- =============================================
-- Author:		[ab]
-- Create date: 20170716
-- Description:	Процедура получения списка параметров
-- для расчетного параметра
-- =============================================

IF OBJECT_ID('[dbo].[ParameterRelationsGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterRelationsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterRelationsGet 
@PrimaryParamID bigint
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		pr.PrimaryParamID,
		pr.SecondaryParamID AS ParameterID,
		p.ParamShortName AS ParameterShortName, 	
		pr.MathOperationID,
		mo.MathOperationShortName
	FROM dbo.ParamRelations AS pr
	JOIN dbo.Params AS p ON p.ParamID = pr.PrimaryParamID
	JOIN dbo.MathOperations AS mo ON mo.MathOperationID = pr.MathOperationID 	
	WHERE PrimaryParamID = @PrimaryParamID 	
END
GO
