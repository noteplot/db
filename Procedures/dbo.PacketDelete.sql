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
	@LoginID		BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT
			   		
	DECLARE 
		@MonitorShortName NVARCHAR(255)		
						
	BEGIN TRY
		BEGIN TRAN
			select top 1 
				@MonitorShortName = m.MonitorShortName 
			FROM dbo.MonitorParams AS mp (holdlock)
			JOIN dbo.Monitors AS m ON m.MonitorID = mp.MonitorID
			WHERE mp.ParameterID = @PacketID			
			IF @@ROWCOUNT != 0 
			BEGIN
				SET @ErrorMessage = 'Данный пакет входит в монитор %s. Перед удалением необходимо исключить его из монитора.. ';					
				RAISERROR(@ErrorMessage,16,1,@MonitorShortName);
			END
						
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
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();				
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
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
