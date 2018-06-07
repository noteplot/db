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
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT
	
	DECLARE @lv table(
		LoginView NVARCHAR(128)
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
		IF @@TRANCOUNT != 0 
			ROLLBACK;
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();				
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH
END
GO