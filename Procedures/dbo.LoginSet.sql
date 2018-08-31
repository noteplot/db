set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 23.03.2018
-- Description:	Учетная запись
-- =============================================

IF OBJECT_ID('[dbo].[LoginSet]', 'P') is null
 EXEC('create procedure [dbo].[LoginSet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[LoginSet]
@LoginID bigint,
@Password nvarchar(128),
@ScreenName nvarchar(64),
@ShowScreenName BIT,
@LoginView nvarchar(128) out
AS
BEGIN
	SET NOCOUNT ON;	
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.LoginSet';--
			
	DECLARE @lv table(
		LoginView NVARCHAR(128) NULL
	)	
			
	BEGIN TRY
		BEGIN TRAN
			UPDATE [dbo].[Logins]
			SET
				Password = @Password,
				ScreenName = @ScreenName,
				ShowScreenName = @ShowScreenName
				OUTPUT inserted.LoginView INTO @lv		
			WHERE LoginID = @LoginID
			
			SELECT @LoginView = LoginView FROM @lv
		COMMIT
	END TRY	
	BEGIN CATCH	
		IF @@TRANCOUNT > 0 ROLLBACK 	
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback= 1;
		RETURN 1;	
	END CATCH
END
GO