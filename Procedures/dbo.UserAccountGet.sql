set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 23.03.2018
-- Description:	Учетная запись
-- =============================================

IF OBJECT_ID('[dbo].[UserAccountGet]', 'P') is null
 EXEC('create procedure [dbo].[UserAccountGet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[UserAccountGet]
@LoginID bigint
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.UserAccountGet';--
	BEGIN TRY			
		SELECT 
			l.LoginID,
			l.LoginName,
			l.Password,
			l.Email,
			l.ScreenName,
			l.ShowScreenName,
			l.IsConfirmed,
			lr.LoginRoleShortName as LoginRoleName   
		FROM dbo.Logins as l
		JOIN dbo.LoginRoles as lr on lr.LoginRoleID = l.LoginRoleID 
		WHERE LoginID = @LoginID
	END TRY
	BEGIN CATCH
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  	 					
END
GO