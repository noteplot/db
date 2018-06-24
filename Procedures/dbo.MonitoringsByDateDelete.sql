set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171202
-- Description:	Процедура удаления измерений по монитору за период
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringsByDateDelete]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringsByDateDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringsByDateDelete 
@MonitorID	BIGINT,
@DateFrom	DATETIME2(0),
@DateTo		DATETIME2(0),
@DeletedRows	INT = 0 OUT
AS
BEGIN
	DECLARE 
		@dt1 DATETIME2(0),@dt2 DATETIME2(0),@cd DATETIME2(0) = GETDATE(),
		@ErrorMessage	NVARCHAR(4000),
		@ErrorSeverity	INT,	
		@ErrorState		INT
		 	
	IF @DateTo IS NULL 
		SET @dt2 = cast(DATEADD(dd,1,@cd) AS DATE)
	ELSE
		SET @dt2 = cast(DATEADD(dd,1,@DateTo) AS DATE)

	IF @DateFrom IS NULL
		SET @dt1 = cast(DATEADD(dd,-1,@dt2) AS DATE)
	ELSE
		SET @dt1 = cast(@DateFrom AS DATE);					
			 
	SET NOCOUNT ON;
	BEGIN TRY
		IF @dt1 >= @dt2
			RAISERROR('Некорректно указан период!',16,1)
		BEGIN TRAN
			DELETE m
			FROM dbo.Monitorings AS m
			WHERE
				m.MonitorID = @MonitorID		
				AND m.MonitoringDate >= @dt1
				AND m.MonitoringDate < @dt2
				
			SET @DeletedRows = @@ROWCOUNT;
							
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
		RETURN 1	
	END CATCH
		
END	
GO
