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
			
	BEGIN TRY
		BEGIN TRAN
		update [dbo].[Logins]
			set
				Password = @Password,
				ScreenName = @ScreenName,
				ShowScreenName = @ShowScreenName
		where LoginID = @LoginID
		SELECT @LoginView = LoginView FROM [dbo].[Logins]
		WHERE LoginID = @LoginID
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