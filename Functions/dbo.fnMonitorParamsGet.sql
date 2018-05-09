set quoted_identifier, ansi_nulls ON
GO
-- ============================================================
-- Author:		[ab]
-- Create date: 20171221
-- Description:	Cписок параметров (простые и расчетные)
-- монитора, которые используются в мониторинге
-- ============================================================

--if OBJECT_ID('dbo.fnMonitorParamsGet') is NULL
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnMonitorParamsGet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 exec('create function dbo.fnMonitorParamsGet(@MonitorID bigint, @LoginID bigint) RETURNS TABLE AS RETURN (select 1 as ''1'')')
go

ALTER FUNCTION [dbo].[fnMonitorParamsGet]
( 
 @MonitorID BIGINT,
 @ParameterID BIGINT = NULL,
 @LoginID BIGINT,
 @Active TINYINT = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH par as (	
	SELECT
	m.MonitorID,
	mp.MonitorParamID,
	mp.MonitorParamPosition,
	PacketParamPosition = 0,
	p.ParameterID,
	m.LoginID,
	[Active] = IIF(mp.[Active] = 0, 0, p.[Active])
	FROM dbo.Monitors AS m
	JOIN  dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
	JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID AND p.ParameterKindID = 0		 
	UNION ALL
	SELECT
	m.MonitorID,
	mp.MonitorParamID,
	mp.MonitorParamPosition,
	pp.PacketParamPosition, 
	p1.ParameterID,
	m.LoginID,
	active = IIF(mp.[Active] = 0, 0, CASE WHEN p1.[Active] = 0 THEN p1.[Active]
				ELSE p.[Active]
			END)
	FROM dbo.Monitors AS m		
	JOIN  dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
	JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID AND p.ParameterKindID = 1 
	JOIN dbo.Packets AS pt ON pt.PacketID = mp.ParameterID
	JOIN dbo.PacketParams AS pp ON pp.PacketID = pt.PacketID
	JOIN dbo.Parameters AS p1 ON p1.ParameterID = pp.ParamID AND p1.ParameterKindID = 0 
	)
		
	SELECT
		par.MonitorID,
		par.MonitorParamID,
		par.ParameterID,
		m.MonitorShortName,
		p.ParamShortName AS ParameterShortName,
		p.ParamName AS ParameterName,
		p.ParamTypeID AS ParameterTypeID,
		p.ParamValueMAX AS ParameterValueMax,
		p.ParamValueMIN AS ParameterValueMin,
		u.UnitID AS ParameterUnitID,
		u.UnitShortName AS ParameterUnitShortName,
		u.UnitName AS ParameterUnitName,
		p.ParamValueTypeID,
		pvt.Scale AS ParameterScale,
		pvt.[Precision] AS ParameterPrecision,
		par.LoginID,
		par.[Active],
		par.MonitorParamPosition,
		par.PacketParamPosition
	FROM par
	JOIN dbo.Params AS p ON p.ParamID = par.ParameterID AND p.ParamTypeID IN (0,1)
	JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID
	JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID
	JOIN dbo.Monitors AS m ON m.MonitorID = par.MonitorID
	WHERE par.MonitorID = @MonitorID AND par.ParameterID = ISNULL(@ParameterID,par.ParameterID) AND  par.LoginID IN (0,@LoginID)
	AND par.[Active] = ISNULL(@Active,par.[Active])		
	--ORDER BY par.MonitorParamPosition,par.PacketParamPosition		
)	

go