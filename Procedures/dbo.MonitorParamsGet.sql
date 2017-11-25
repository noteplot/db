-- ============================================================
-- Author:		[ab]
-- Create date: 20171118
-- Description:	Процедура списка параметров монитора
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorParamsGet
@MonitorID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @PackName VARCHAR(255) = 'Пакет'; 
	SELECT 
		m.MonitorID					AS MonitorID,
		mp.ParameterID				AS ParameterID,
		
		IIF(pc.PacketID IS NOT NULL, pm.ParamShortName, pc.PacketShortName) AS ParameterShortName,
		IIF(pc.PacketID IS NOT NULL, pm.ParamName, pc.PacketName) AS ParameterName,
		pm.ParamTypeID				AS ParameterTypeID,
		IIF(pc.PacketID IS NOT NULL, pt.ParamTypeName, @PackName) AS ParameterTypeName,

		mp.MonitorParamPosition		AS MonitorParamPosition,		
		pv.MonitorParamValue		AS MonitorParameterValue,			
		mp.[Active]					AS MonitorParameterActive 
	FROM dbo.Monitors AS m
	JOIN dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
	JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID
	LEFT JOIN dbo.Params AS pm ON pm.ParamID = p.ParameterID
	LEFT JOIN dbo.ParamTypes AS pt ON pt.ParamTypeID = pm.ParamTypeID
	LEFT JOIN dbo.MonitorTotalParamValues AS pv ON pv.MonitorParamID = mp.MonitorParamID
	LEFT JOIN dbo.Packets AS pc ON pc.PacketID = p.ParameterID
	WHERE 
		m.MonitorID = @MonitorID
	ORDER BY mp.MonitorParamPosition
END
GO	