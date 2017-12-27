-- =============================================
-- Author:		[ab]
-- Create date: 20171226
-- Description:	Удаление измерения по монитору
-- =============================================

IF OBJECT_ID('[dbo].[MonitoringDelete]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringDelete 
	@MonitoringID		BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
						
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM dbo.MonitoringParams
			WHERE MonitoringID = @MonitoringID
					
			DELETE FROM dbo.Monitorings
			WHERE MonitoringID = @MonitoringID

			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
			ROLLBACK;
		SET @ErrorMessage = ERROR_MESSAGE();				
		RAISERROR(@ErrorMessage,16,1);
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
