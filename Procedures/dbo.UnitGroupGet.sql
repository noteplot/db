-- ============================================================
-- Author:		[ab]
-- Create date: 20180204
-- Description:	Процедура получения списка групп едюизмерений
-- ============================================================

IF OBJECT_ID('[dbo].[UnitGroupGet]', 'P') is null
 EXEC('create procedure [dbo].[UnitGroupGet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[UnitGroupGet]
@UnitGroupID	BIGINT = null,
@LoginID		BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		u.UnitGroupID,
		u.UnitGroupShortName,
		u.UnitGroupName,
		u.LoginID
	FROM dbo.UnitGroups AS u
	WHERE 
	u.UnitGroupID = IsNull(@UnitGroupID,u.UnitGroupID) and
	u.LoginID IN (0,@LoginID) 
END	
