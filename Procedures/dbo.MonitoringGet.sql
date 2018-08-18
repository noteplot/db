set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171202
-- Description:	Процедура получения мониторинга
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringGet 
@MonitoringID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitoringGet';--
		
	BEGIN TRY
		SELECT 
			mg.MonitoringID				AS MonitoringID,
			mg.MonitorID				AS MonitorID,
			m.MonitorShortName			AS MonitorShortName,				
			mg.MonitoringDate			AS MonitoringDate,
			mg.MonitoringComment		AS MonitoringComment, 
			mg.CreationDateUTC			AS CreationDateUTC,
			mg.ModifiedDateUTC			AS ModifiedDateUTC		 
		FROM dbo.Monitorings AS mg
		join dbo.Monitors AS m ON m.MonitorID = mg.MonitorID
		WHERE
			mg.MonitoringID = @MonitoringID
	END TRY
	BEGIN CATCH
		DECLARE @LoginID BIGINT
		SELECT @LoginID = m.LoginID FROM dbo.Monitorings AS mg (nolock)
		JOIN dbo.Monitors AS m (nolock) ON m.MonitorID = mg.MonitorID 
		WHERE mg.MonitoringID = @MonitoringID
			
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 
END	
GO
