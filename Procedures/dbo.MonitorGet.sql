-- ============================================================
-- Author:		[ab]
-- Create date: 20171111
-- Description:	Процедура получения списка мониторов или монитора
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorGet
@MonitorID	BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		m.MonitorID					AS MonitorID,
		m.MonitorShortName			AS MonitorShortName,
		m.MonitorName				AS MonitorName,		
		m.LoginID					AS LoginID,
		m.[Active]					AS [Active] 
	FROM dbo.Monitors AS m
	WHERE 
		m.LoginID IN (0,@LoginID) 
END	
GO
