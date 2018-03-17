-- ============================================================
-- Author:		[ab]
-- Create date: 20171111
-- Description:	ѕроцедура получени€ набора параметров измерений
-- мониторам за период дл€ графиков
-- @MonitorParams - строка MonitorParamID через зап€тую
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
	select 
		c.value('.[1]','bigint') AS MonitorParamID
	from 
		@MonitorParams.nodes('/MonitorParams/MonitorParamID') t(c)
	

END