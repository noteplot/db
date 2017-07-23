-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	Процедура получения списка групп параметров
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGroupsGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGroupsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGroupsGet
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ParameterGroupID,
		ParameterGroupShortName,				
		ParameterGroupName,
		LoginID
	FROM dbo.ParameterGroups
	WHERE LoginID IN (0,@LoginID) 
END	
GO
