set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 27.01.2018
-- Description:	Данные регистрации
-- =============================================

IF OBJECT_ID('[dbo].[LoginGet]', 'P') is null
 EXEC('create procedure [dbo].[LoginGet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[LoginGet]
@Login NVARCHAR(64),
@Password NVARCHAR(128) = '',
@Mode  TINYINT = 0				-- 0 - поиск по LoginName 1 - поиск по EMail
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE
			@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--'dbo.LoginGet'--
			
		IF @Mode = 0	
			SELECT * FROM dbo.Logins WHERE LoginName = @Login AND Password = @Password 
		ELSE
		IF @Mode = 1
			SELECT * FROM dbo.Logins WHERE Email = @Login		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = null, @ProcName = @ProcName, @Reraise = 1, @rollback= 1
		RETURN 1;
	END CATCH
END
GO