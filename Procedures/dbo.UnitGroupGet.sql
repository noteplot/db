set quoted_identifier, ansi_nulls on
GO

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
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.UnitGroupGet';--
	BEGIN TRY	
		SELECT
			u.UnitGroupID,
			u.UnitGroupShortName,
			u.UnitGroupName,
			u.LoginID
		FROM dbo.UnitGroups AS u
		WHERE 
		u.UnitGroupID = IsNull(@UnitGroupID,u.UnitGroupID) and
		u.LoginID IN (0,@LoginID)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  						  	 
END	
GO