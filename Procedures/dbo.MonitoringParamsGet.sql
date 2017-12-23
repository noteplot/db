-- ============================================================
-- Author:		[ab]
-- Create date: 20171221
-- Description:	Cписок параметров (простые и рассчетные)
-- измерений(мониторинга)
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringParamsGet
@MonitorID	BIGINT,
@MonitoringID BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF @MonitoringID IS NULL
	BEGIN
		;WITH par as (	
		SELECT
		mp.MonitorParamID,
		mp.MonitorParamPosition,
		PacketParamPosition = 0,
		p.ParameterID
		FROM dbo.Monitors AS m
		JOIN  dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
		AND mp.[Active] = 1
		JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID AND p.ParameterKindID = 0 
		and p.[Active] = 1
		WHERE m.MonitorID =@MonitorID
		UNION ALL
		SELECT
		mp.MonitorParamID,
		mp.MonitorParamPosition,
		pp.PacketParamPosition, 
		p1.ParameterID
		FROM dbo.Monitors AS m
		JOIN  dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
		AND mp.[Active] = 1
		JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID AND p.ParameterKindID = 1 AND p.[Active] = 1
		JOIN dbo.Packets AS pt ON pt.PacketID = mp.ParameterID
		JOIN dbo.PacketParams AS pp ON pp.PacketID = pt.PacketID
		JOIN dbo.Parameters AS p1 ON p1.ParameterID = pp.ParamID AND p1.ParameterKindID = 0 AND p1.[Active] = 1
		WHERE m.MonitorID =@MonitorID
		)
		
		SELECT
			cast(NULL AS BIGINT) AS MonitoringID,
			cast(NULL AS BIGINT) AS MonitoringParamID,  
			par.MonitorParamID,
			par.ParameterID,
			cast(null as decimal(28,6)) as ParamValue,
			p.ParamShortName AS ParameterShortName,
			p.ParamName AS ParameterName,
			p.ParamTypeID,
			p.ParamValueMAX,
			p.ParamValueMIN,
			u.UnitID AS ParameterUnitID,
			u.UnitShortName AS ParameterUnitShortName,
			p.ParamValueTypeID,
			pvt.Scale AS ParameterScale,
			pvt.[Precision] AS ParameterPrecision,
			cast(null as datetime) as CreationDateUTC,
			cast(null as datetime) as ModifiedDateUTC
		FROM par
		JOIN dbo.Params AS p ON p.ParamID = par.ParameterID AND p.ParamTypeID IN (0,1)
		JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID
		JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID
		ORDER BY par.MonitorParamPosition,par.PacketParamPosition				
	END
	ELSE
	BEGIN
		SELECT
			mp.MonitoringID,
			mp.MonitoringParamID,  
			mp.MonitorParamID,
			mp.ParamID,
			mp.ParamValue,
			p.ParamShortName AS ParameterShortName,
			p.ParamName AS ParameterName,			
			p.ParamTypeID,
			p.ParamValueMAX,
			p.ParamValueMIN,
			u.UnitID AS ParameterUnitID,
			u.UnitShortName AS ParameterUnitShortName,
			p.ParamValueTypeID,
			pvt.Scale AS ParameterScale,
			pvt.[Precision] AS ParameterPrecision,
			mp.CreationDateUTC,
			mp.ModifiedDateUTC
		FROM dbo.MonitoringParams AS mp
		JOIN dbo.Params AS p ON p.ParamID = mp.ParamID
		JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID
		JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID				 
		WHERE mp.MonitoringID = @MonitoringID			
	END	
END
GO	