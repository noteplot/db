-- =============================================
-- Author:		[ab]
-- Create date: 20170813
-- Description:	Удаление параметра
-- =============================================

IF OBJECT_ID('[dbo].[ParameterDelete]', 'P') is null
 EXEC('create procedure [dbo].[ParameterDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterDelete 
	@ParameterID		BIGINT,
	@LoginID			BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
						
	BEGIN TRY
		BEGIN TRAN
			IF EXISTS(SELECT 1 FROM dbo.PacketParams WHERE ParamID = @ParameterID)
			BEGIN
				set @ErrorMessage = 'Данный параметр входит в пакет. Перед удалением необходимо исключить его из пакета.'
				RAISERROR(@ErrorMessage,16,1);
			END 

			IF EXISTS(SELECT 1 FROM dbo.ParamRelations WHERE SecondaryParamID = @ParameterID)
			BEGIN
				set @ErrorMessage = 'Данный параметр используется для вычисления других параметров. Перед удалением необходимо исключить его из расчетов.'
				RAISERROR(@ErrorMessage,16,1);
			END 
			
			DELETE FROM dbo.ParamRelations	-- AFTER trigger
			WHERE 	
					PrimaryParamID = @ParameterID
			
			DELETE FROM dbo.Params	-- AFTER trigger
			WHERE 	
					ParamID = @ParameterID
					AND LoginID = @LoginID

			DELETE FROM dbo.Parameters
			WHERE 	
					ParameterID = @ParameterID
										
			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
			ROLLBACK;
		SET @ErrorMessage = ERROR_MESSAGE();				
		RAISERROR(@ErrorMessage,16,4);
		/* 
			SELECT
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage
		*/
	END CATCH	  
END
GO
