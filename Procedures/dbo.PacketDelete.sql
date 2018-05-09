set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20171106
-- Description:	Удаление пакета
-- =============================================

IF OBJECT_ID('[dbo].[PacketDelete]', 'P') is null
 EXEC('create procedure [dbo].[PacketDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.PacketDelete 
	@PacketID		BIGINT,
	@LoginID			BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
						
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM dbo.PacketParams
			WHERE 	
					PacketID = @PacketID
		
			DELETE FROM dbo.Packets	-- AFTER trigger -> delete Parameters ??
			WHERE 	
					PacketID = @PacketID
					AND LoginID = @LoginID

			DELETE FROM dbo.Parameters
			WHERE 	
					ParameterID = @PacketID

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
