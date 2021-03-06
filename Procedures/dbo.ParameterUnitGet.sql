set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20170902
-- Description:	Процедура получения списка ед.изм для логина
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterUnitGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterUnitGet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[ParameterUnitGet]
@UnitID		BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.ParameterUnitGet';--
		
	BEGIN TRY	
		SELECT
			u.UnitID,
			u.UnitShortName,
			u.UnitName,
			u.UnitGroupID,
			ug.UnitGroupShortName,
			ug.UnitGroupName,
			u.LoginID
		FROM dbo.Units AS u
		JOIN dbo.UnitGroups AS ug ON ug.UnitGroupID = u.UnitGroupID
		WHERE 
		u.UnitID = IsNull(@UnitID,u.UnitID) and
		u.LoginID IN (0,@LoginID)
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 	
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 									   	 	 
END	
GO