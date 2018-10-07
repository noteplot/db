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
						
	DECLARE
		@ResourceLimitID INT = 3 -- кол-во пакетов по логину

	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.PacketDelete';--
						
	BEGIN TRY
		BEGIN TRAN
			select top 1 
				@MonitorShortName = m.MonitorShortName 
			FROM dbo.MonitorParams AS mp (REPEATABLEREAD)
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
					
			-- уменьшение счетчика
			UPDATE dbo.ResourceCounts
				SET [Value] -= 1
			WHERE LoginID = @LoginID AND ResourceLimitID = @ResourceLimitID

			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  
END
GO
