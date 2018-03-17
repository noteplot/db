-- ============================================================
-- Author:		[ab]
-- Create date: 20180317
-- Description:	C����� ���� ��������� ���������� ��� ������� ������
-- ============================================================

IF OBJECT_ID('[dbo].[ReportMonitorParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[ReportMonitorParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ReportMonitorParamsGet
@LoginID	BIGINT,
@Active		TINYINT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		p.MonitorParamID,
		p.ParameterShortName AS ParamShortName,
		m.MonitorShortName,
		p.ParameterUnitShortName AS UnitShortName,
		[Active] = IIF(m.[Active] = 0, 0, p.[Active]),
		@LoginID AS LoginID  
	FROM dbo.Monitors AS m
	cross apply dbo.[fnMonitorParamsGet](m.MonitorID,@LoginID,@Active) AS p	
	WHERE m.LoginID IN (0,@LoginID)
	AND m.[Active] = ISNULL(@Active,m.[Active])
		
END
GO	