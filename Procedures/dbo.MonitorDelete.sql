set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20171125
-- Description:	Удаление монитора
-- =============================================

IF OBJECT_ID('[dbo].[MonitorDelete]', 'P') is null
 EXEC('create procedure [dbo].[MonitorDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorDelete 
	@MonitorID		BIGINT,
	@LoginID			BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
	DECLARE
		@ResourceLimitID INT = 1; -- кол-во мониторов по логину
						
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS(
				SELECT 1 FROM dbo.Monitors (updlock) 
				WHERE 
				MonitorID = @MonitorID			
				AND LoginID	= @LoginID 				
			)	
				RAISERROR('Монитор не существует!',16,1);
				
			IF EXISTS(SELECT 1 FROM dbo.Monitorings AS m (updlock) WHERE m.MonitorID = @MonitorID)
				RAISERROR('По данному монитору есть измерения!',16,2);
				
			DELETE v 
			FROM dbo.MonitorTotalParamValues AS v
			JOIN dbo.MonitorParams AS p ON p.MonitorID = @MonitorID AND p.MonitorParamID = v.MonitorParamID
		
			DELETE FROM dbo.MonitorParams
			WHERE 	
					MonitorID = @MonitorID
		
			DELETE FROM dbo.Monitors	-- AFTER trigger -> delete Parameters ??
			WHERE 	
					MonitorID = @MonitorID
					AND LoginID = @LoginID

			-- уменьшение счетчика
			UPDATE dbo.ResourceCounts
				SET [Value] -= 1
			WHERE LoginID = @LoginID AND ResourceLimitID = @ResourceLimitID
					
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
