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
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.ParamValueTypesGet';--
		
	BEGIN TRY		
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
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = NULL, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  	
END
GO
