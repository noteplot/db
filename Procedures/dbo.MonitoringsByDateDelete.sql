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
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitoringsByDateDelete';--		 	

	DECLARE 
		@dt1 DATETIME2(0),@dt2 DATETIME2(0),@cd DATETIME2(0) = GETDATE()
		
	IF @DateTo IS NULL 
		SET @dt2 = cast(DATEADD(dd,1,@cd) AS DATE)
	ELSE
		SET @dt2 = cast(DATEADD(dd,1,@DateTo) AS DATE)

	IF @DateFrom IS NULL
		SET @dt1 = cast(DATEADD(dd,-1,@dt2) AS DATE)
	ELSE
		SET @dt1 = cast(@DateFrom AS DATE);					
			 
	BEGIN TRY
		IF @dt1 >= @dt2
			RAISERROR('Некорректно указан период!',16,1)
		BEGIN TRAN
			DELETE mp
			FROM dbo.MonitoringParams AS mp 
			JOIN dbo.Monitorings AS m ON m.MonitoringID = mp.MonitoringID
			WHERE
				m.MonitorID = @MonitorID		
				AND m.MonitoringDate >= @dt1
				AND m.MonitoringDate < @dt2
		
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
		IF @@TRANCOUNT > 0 ROLLBACK
		DECLARE @LoginID BIGINT
		SELECT @LoginID = m.LoginID FROM dbo.Monitors AS m (nolock)
		WHERE m.MonitorID = @MonitorID
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;			
	END CATCH
		
END	
GO
