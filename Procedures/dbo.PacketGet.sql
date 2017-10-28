-- ============================================================
-- Author:		[ab]
-- Create date: 20170916
-- Description:	Процедура получения списка пакетов или пакета
-- ============================================================

IF OBJECT_ID('[dbo].[PacketGet]', 'P') is null
 EXEC('create procedure [dbo].[PacketGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.PacketGet
@PacketID	BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ps.ParameterID					AS ParameterID,
		ps.ParameterGroupID				AS ParameterGroupID,
		pg.ParameterGroupShortName		AS ParameterGroupShortName,
		ps.[Active]						AS [Active], 
		p.LoginID						AS LoginID
	FROM dbo.Packets AS p
	JOIN dbo.Parameters AS ps ON ps.ParameterID = p.PacketID
	JOIN dbo.ParameterGroups AS pg ON pg.ParameterGroupID = ps.ParameterGroupID
	WHERE 
		ps.ParameterID = IsNull(@PacketID,ps.ParameterID) and
		p.LoginID IN (0,@LoginID) 
END	
GO
