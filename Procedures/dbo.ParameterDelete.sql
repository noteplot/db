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
			DELETE FROM dbo.Params	-- AFTER trigger
			WHERE 	
					ParamID = @ParameterID
					AND LoginID = @LoginID					
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
