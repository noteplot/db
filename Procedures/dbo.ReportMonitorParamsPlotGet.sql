-- ============================================================
-- Author:		[ab]
-- Create date: 20171111
-- Description:	Процедура получения набора параметров измерений
-- мониторам за период для графиков
-- @MonitorParams - XML:
--  <MonitorParams>
--		<MonitorParamID>1</MonitorParamID>
--		<MonitorParamID>2</MonitorParamID>
--	</MonitorParams>
-- ============================================================

IF OBJECT_ID('[dbo].[ReportMonitorParamsPlotGet]', 'P') is null
 EXEC('create procedure [dbo].[ReportMonitorParamsPlotGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ReportMonitorParamsPlotGet
@MonitorParams	XML,
@LoginID		BIGINT,
@DateBegin		DATE = NULL,
@DateEnd		DATE = NULL,
@DebugMode		TINYINT = 0 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@DB DATE, @DE DATE
		
	SET @DE = DATEADD(dd,1,IsNull(@DateEnd,GETDATE()));
	SET @DB = IsNull(@DateBegin,DATEADD(mm,-1,@DateEnd));
		
	;WITH pm AS (
	select 
		c.value('ParamID[1]','bigint') AS ParamID,
		c.value('MonitorID[1]','bigint') AS MonitorID
	from 
		@MonitorParams.nodes('/Report/ReportParam') t(c)
	)
	
	SELECT 
		convert(varchar(20),m.[MonitoringDate],104) as [MonitoringDate],
		p.ParameterShortName AS ParamShortName, 
		p.ParameterUnitShortName AS UnitShortName,
		p.MonitorShortName,
		p.ParameterShortName+' ('+p.ParameterUnitShortName+')' as ParameterName, 
		mp.ParamValue as ParamValue 	
	FROM pm
	JOIN dbo.Monitorings AS m ON m.MonitorID = pm.MonitorID
	JOIN dbo.MonitoringParams AS mp ON mp.MonitoringID = m.MonitoringID AND mp.ParamID = pm.ParamID
	CROSS APPLY dbo.fnMonitorParamsGet(pm.MonitorID,pm.ParamID,@LoginID,NULL) as p 	
	WHERE
		m.[MonitoringDate] >=@DB and m.[MonitoringDate] < @DE  
		

END