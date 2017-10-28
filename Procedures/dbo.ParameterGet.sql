-- ============================================================
-- Author:		[ab]
-- Create date: 20170916
-- Description:	Процедура получения списка параметров или параметра
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGet
@ParameterID BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ps.ParameterID					AS ParameterID,
		ps.ParameterGroupID				AS ParameterGroupID,
		pg.ParameterGroupShortName		AS ParameterGroupShortName,
		p.ParamShortName				AS ParameterShortName,
		p.ParamName						AS ParameterName,
		p.ParamUnitID					AS ParameterUnitID,
		u.UnitShortName					AS ParameterUnitShortName,
		p.ParamTypeID					AS ParameterTypeID,
		pt.ParamTypeName				AS ParameterTypeName,
		p.ParamValueTypeID				AS ParameterValueTypeID,
		pvt.ParamValueTypeShortName		AS ParameterValueTypeShortName,
		p.ParamValueMAX					AS ParameterValueMAX,
		p.ParamValueMIN					AS ParameterValueMIN,
		ps.[Active]						AS Active,
		p.LoginID						AS LoginID
	FROM dbo.Params AS p
	JOIN dbo.Parameters AS ps ON ps.ParameterID = p.ParamID
	JOIN dbo.ParameterGroups AS pg ON pg.ParameterGroupID = ps.ParameterGroupID
	JOIN dbo.Units AS u ON u.UnitID = p.ParamUnitID
	JOIN dbo.ParamTypes AS pt ON pt.ParamTypeID = p.ParamTypeID
	JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID 	
	WHERE 
	ps.ParameterID = IsNull(@ParameterID,ps.ParameterID) and
	p.LoginID IN (0,@LoginID) 
END	
GO
