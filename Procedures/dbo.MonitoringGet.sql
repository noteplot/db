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
END	
GO
