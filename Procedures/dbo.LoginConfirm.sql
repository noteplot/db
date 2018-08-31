set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 27.01.2018
-- Description:	Регистрация логина(пользователя)
-- =============================================

IF OBJECT_ID('[dbo].[LoginConfirm]', 'P') is null
 EXEC('create procedure [dbo].[LoginConfirm] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[LoginConfirm]
@LoginID INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.LoginConfirm';--
	
	BEGIN TRY		
		BEGIN TRAN
			IF NOT EXISTS (		
			SELECT 1 FROM dbo.Logins(updlock) WHERE LoginID = @LoginID)
			BEGIN
				RAISERROR('Данная учетная запись не существует!',16,1)
			END
				
			UPDATE dbo.Logins
				set IsConfirmed = 1
			where LoginID = @LoginID
			and IsConfirmed = 0
			if @@ROWCOUNT = 0 
				RAISERROR('Вы уже авторизованы!',16,1)
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH
END
GO