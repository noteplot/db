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
@ShowScreenName bit
AS
BEGIN
	SET NOCOUNT ON;
	update [dbo].[Logins]
		set
			Password = @Password,
			ScreenName = @ScreenName,
			ShowScreenName = @ShowScreenName 		 
	where LoginID = @LoginID				
END