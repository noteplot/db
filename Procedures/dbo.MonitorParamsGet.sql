-- ============================================================
-- Author:		[ab]
-- Create date: 20171118
-- Description:	Процедура получения параметров монитора
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorParamsGet
@MonitorID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		m.MonitorID					AS MonitorID,
		mp.ParameterID				AS ParameterID,
		p.ParamShortName			AS ParameterShortName,
		p.ParamName					AS ParameterName,
		p.ParamTypeID				AS ParameterTypeID,
		pt.ParamTypeName			AS ParameterTypeName, 		
		mp.MonitorParamPosition		AS MonitorParamPosition,		
		pv.MonitorParamValue		AS MonitorParamValue,			
		mp.[Active]					AS MonitorParameterActive 
	FROM dbo.Monitors AS m
	JOIN dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
	JOIN dbo.Params AS p ON p.ParamID = mp.ParameterID
	JOIN dbo.ParamTypes AS pt ON pt.ParamTypeID = p.ParamTypeID
	LEFT JOIN dbo.MonitorTotalParamValues AS pv ON pv.MonitorParamID = mp.MonitorParamID
	WHERE 
		m.MonitorID = @MonitorID
	ORDER BY mp.MonitorParamPosition
END
GO	