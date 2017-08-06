-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	Процедура получения списка групп параметров
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGroupGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGroupGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGroupGet
@ParameterGroupID BIGINT = null,
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
	WHERE 
	ParameterGroupID = IsNull(@ParameterGroupID,ParameterGroupID) and
	LoginID IN (0,@LoginID) 
END	
GO
