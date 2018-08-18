set quoted_identifier, ansi_nulls on
GO

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
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.ParameterRelationsGet';--
		
	BEGIN TRY	
		SELECT 
			pr.PrimaryParamID,
			pr.SecondaryParamID AS ParameterID,
			p.ParamShortName AS ParameterShortName, 	
			pr.MathOperationID,
			mo.MathOperationShortName,
			mo.MathOperationName,
			mo.MathOperationShortName + ' ('+mo.MathOperationName+')' AS MathOperationFullName
		FROM dbo.ParamRelations AS pr
		JOIN dbo.Params AS p ON p.ParamID = pr.SecondaryParamID
		JOIN dbo.MathOperations AS mo ON mo.MathOperationID = pr.MathOperationID 	
		WHERE PrimaryParamID = @PrimaryParamID
		ORDER BY pr.ParamRelationPosition
	END TRY	
	BEGIN CATCH
		EXEC [dbo].[ErrorLogSet] @LoginID = NULL, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 									   	 	 	
END
GO
