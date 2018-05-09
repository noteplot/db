set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20180225
-- Description:	Итоговые параметры монитора (активные)
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorTotalParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorTotalParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorTotalParamsGet
@MonitorID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;
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
			@MonitorID AS MonitorID,
			par.MonitorParamID,
			par.ParameterID,
			p.ParamShortName AS ParameterShortName,
			p.ParamName AS ParameterName,
			mtpv.MonitorParamValue AS MonitorParameterValue,
			u.UnitID AS ParameterUnitID,
			u.UnitShortName AS ParameterUnitShortName,
			p.ParamValueTypeID,
			pvt.Scale AS ParameterScale,
			pvt.[Precision] AS ParameterPrecision
		FROM par
		JOIN dbo.Params AS p ON p.ParamID = par.ParameterID AND p.ParamTypeID = 2 -- параметр монитора
		JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID
		JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID
		JOIN dbo.MonitorTotalParamValues AS mtpv ON mtpv.MonitorParamID = par.MonitorParamID
		ORDER BY par.MonitorParamPosition,par.PacketParamPosition			
END;
GO