set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20170924
-- Description:	Процедура получения списка опрераций с параметрами
-- ============================================================

IF OBJECT_ID('[dbo].[MathOperationsGet]', 'P') is null
 EXEC('create procedure [dbo].[MathOperationsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MathOperationsGet 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		mo.MathOperationID,
		mo.MathOperationShortName,
		mo.MathOperationName,
		mo.MathOperationShortName + ' ('+mo.MathOperationName+')' AS MathOperationFullName  
	FROM dbo.MathOperations AS mo
END	
GO
