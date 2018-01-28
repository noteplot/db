-- =============================================
-- Author:		[ab]
-- Create date: 20180121
-- Description:	Создание учетной записи
-- =============================================

IF OBJECT_ID('[dbo].[LoginCreate]', 'P') is null
 EXEC('create procedure [dbo].[LoginCreate] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[LoginCreate]
@LoginName		NVARCHAR(64),
@Password		NVARCHAR(128),
@Email			NVARCHAR(64) = null,
@LoginRoleID	INT = NULL,
@ScreenName		NVARCHAR(64) = NULL,
@ShowScreenName BIT = 0,
@LoginID		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM dbo.Logins WHERE LoginName = @LoginName)
		BEGIN
			RAISERROR('Такой логин уже существует!',16,1)
		END
		
		IF @Email IS NULL 
		SET @Email = @LoginName
		
		if @LoginRoleID is null
		set @LoginRoleID = 3

		BEGIN TRAN
		
			INSERT INTO dbo.Logins
			(
				LoginRoleID,
				LoginName,
				[Password],
				Email,
				ScreenName,
				ShowScreenName
			)
			VALUES(
				@LoginRoleID,
				@LoginName,
				@Password,
				@Email,
				@ScreenName,
				@ShowScreenName				
				)			
				set @LoginID = SCOPE_IDENTITY();
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