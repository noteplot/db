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
	BEGIN TRY
		IF NOT EXISTS (		
		SELECT 1 FROM dbo.Logins WHERE LoginID = @LoginID)
		BEGIN
			RAISERROR('Данная учетная запись не существует!',16,1)
		END
		
		BEGIN TRAN		
			UPDATE dbo.Logins
				set IsConfirmed = 1
			where LoginID = @LoginID
			and IsConfirmed = 0
			if @@ROWCOUNT = 0 
				RAISERROR('Вы уже авторизованы!',16,1)
		COMMIT
	END TRY
	BEGIN CATCH
		if @@TRANCOUNT>0 
			ROLLBACK
		DECLARE @errmes varchar(255) = ERROR_MESSAGE();
		raiserror(@errmes,16,1);
		return 1
	END CATCH
	return 0
END
