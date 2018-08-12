set quoted_identifier, ansi_nulls on
GO

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
@ReportMode		TINYINT = 0,
@DebugMode		TINYINT = 0 
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE
		@DB DATE, @DE DATE, @id INT = 1,@rp INT = 0,
		@jArr NVARCHAR(MAX) = '', @ParamID BIGINT,@MonitorID BIGINT,
		@ParamShortName NVARCHAR(255), @MonitorShortName NVARCHAR(255), @UnitShortName NVARCHAR(255)
		
	SET @DE = DATEADD(dd,1,IsNull(@DateEnd,GETDATE()));
	SET @DB = IsNull(@DateBegin,DATEADD(mm,-1,@DateEnd));
	
	DECLARE @pm table (
		ID INT IDENTITY(1,1) PRIMARY KEY,
		ParamID BIGINT NOT NULL,
		MonitorID BIGINT NOT NULL,
		ParamShortName NVARCHAR(255),
		MonitorShortName NVARCHAR(255),
		UnitShortName NVARCHAR(255)		
	)
	
	DECLARE @jpm table (
		ID INT PRIMARY KEY,
		JsonArray VARCHAR(max) NULL	 
	)
	 
	INSERT INTO @pm(ParamID, MonitorID,ParamShortName,MonitorShortName,UnitShortName)	
	select 
		c.value('ParamID[1]','bigint') AS ParamID,
		c.value('MonitorID[1]','bigint') AS MonitorID,
		p.ParamShortName,
		m.MonitorShortName,
		u.UnitShortName			
	from 
		@MonitorParams.nodes('/Report/ReportParam') t(c)
	JOIN dbo.Params AS p ON p.ParamID = c.value('ParamID[1]','bigint')
	JOIN dbo.Monitors AS m ON m.MonitorID = c.value('MonitorID[1]','bigint')
	JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID	  	
		
	SET @rp = @@ROWCOUNT;
	
	IF @ReportMode = 0
	BEGIN
		WHILE (@id <= @rp)
		BEGIN
			SELECT @ParamID = ParamID,@MonitorID = MonitorID,
			@ParamShortName = ParamShortName, @MonitorShortName =MonitorShortName, @UnitShortName = UnitShortName
			FROM @pm AS p
			WHERE ID = @id
		
			set @jArr = '';
		 
			SELECT  
				@jArr = @jArr+',['+'"'+convert(varchar(20),m.[MonitoringDate],126)+'"'+','+cast(mp.ParamValue AS VARCHAR(255))+']'		
			FROM dbo.Monitorings AS m
			JOIN dbo.MonitoringParams AS mp ON mp.MonitoringID = m.MonitoringID AND mp.ParamID = @ParamID 
			CROSS APPLY dbo.fnMonitorParamsGet(m.MonitorID,mp.ParamID,@LoginID,NULL) as p	 	
			WHERE
				m.MonitorID = @MonitorID AND m.[MonitoringDate] >=@DB and m.[MonitoringDate] < @DE
			ORDER BY m.[MonitoringDate] 	
		
			SET @jArr = '['+STUFF(@jArr,1,1,'')+']';
			SET @jArr = '{'+ '"unit":'+'"'+@UnitShortName+'"'+',"yaxis":'+cast(@id AS VARCHAR(255))+',"label":'+ '"'+@ParamShortName+' '+@UnitShortName+'"'+',"color":' +cast(@id-1 AS VARCHAR(255))+ ',"data":'+@jArr+'}';
		
			INSERT INTO @jpm(ID,JsonArray) 
			SELECT @id, @jArr
		
			SET @id += 1;
		END

		SELECT * FROM @jpm
	END
	ELSE
	SELECT 
		convert(varchar(20),m.[MonitoringDate],104) as [MonitoringDate],
		pm.ParamShortName,
		pm.UnitShortName AS UnitShortName,
		pm.MonitorShortName,
		pm.ParamShortName+' ('+pm.UnitShortName+')' as ParameterName, 
		mp.ParamValue as ParamValue 	
	FROM @pm AS pm
	JOIN dbo.Monitorings AS m ON m.MonitorID = pm.MonitorID
	JOIN dbo.MonitoringParams AS mp ON mp.MonitoringID = m.MonitoringID AND mp.ParamID = pm.ParamID
	--CROSS APPLY dbo.fnMonitorParamsGet(pm.MonitorID,pm.ParamID,@LoginID,NULL) as p 	
	WHERE
		m.[MonitoringDate] >=@DB and m.[MonitoringDate] < @DE  
		
/*			
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
*/		

END
GO