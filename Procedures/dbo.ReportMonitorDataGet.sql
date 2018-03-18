-- ============================================================
-- Author:		[ab]
-- Create date: 20171111
-- Description:	Процедура получения набора параметров измерений
-- по монитору за период
-- ============================================================

IF OBJECT_ID('[dbo].[ReportMonitorDataGet]', 'P') is null
 EXEC('create procedure [dbo].[ReportMonitorDataGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ReportMonitorDataGet
@MonitorID	BIGINT,
@LoginID	BIGINT,
@DateBegin	DATE = NULL,
@DateEnd	DATE = NULL,
@Mode		TINYINT = 0, -- 0 - все параметры монитора 1 - только активные
@DebugMode  TINYINT = 0 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @columns NVARCHAR(MAX),@Active BIT;
	IF @Mode = 1 
		SET @Active = 1
	
	IF @DateEnd IS NULL 
		SET @DateEnd = GETDATE();
	IF @DateBegin IS NULL
		SET @DateBegin = DATEADD(mm,-1,@DateEnd);
	-- название столбцов отчета
	set @columns = 
		STUFF(
			(
				select 
					',' +'['+ m.ParameterShortName+' ('+m.ParameterUnitShortName+')'+']'
				from dbo.fnMonitorParamsGet(@MonitorID,NULL,@LoginID,@Active) as m 
				FOR XML PATH('')
			)
		,1,1,'')
		
	declare
		@sql nvarchar(max) = N'SELECT [MonitoringDate] as [Время измерения], @columns
	FROM
	(SELECT 
		convert(varchar(20),m.[MonitoringDate],104) as [MonitoringDate], p.ParameterShortName+'' (''+p.ParameterUnitShortName+'')'' as ParameterName, mp.ParamValue as ParamValue 	
		FROM dbo.Monitorings as m
		JOIN dbo.MonitoringParams AS mp ON mp.MonitoringID = m.MonitoringID
		join dbo.fnMonitorParamsGet(@MonitorID,NULL,@LoginID,@Active) as p on p.ParameterID = mp.ParamID
	 where
	 m.MonitorID = @MonitorID AND 
	 m.[MonitoringDate] between ''@DateBegin'' and ''@DateEnd''    
		) AS SourceTable
	PIVOT
	(
		AVG(ParamValue)
		FOR ParameterName IN (@columns)
	) AS PivotTable'
	set @sql = REPLACE(@sql,'@columns',@columns);
	set @sql = REPLACE(@sql,'@MonitorID',@MonitorID);
	set @sql = REPLACE(@sql,'@LoginID',@LoginID);
	IF @Active IS NULL
		set @sql = REPLACE(@sql,'@Active','NULL');
	else
		set @sql = REPLACE(@sql,'@Active',@Active);
	set @sql = REPLACE(@sql,'@DateBegin',convert(varchar(20),@DateBegin,112))
	set @sql = REPLACE(@sql,'@DateEnd',convert(varchar(20),@DateEnd,112))
	
	IF @DebugMode = 1
		SELECT @sql

	exec SP_EXECUTESQL @sql
END