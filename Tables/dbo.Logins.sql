SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Logins
( 
	LoginID             bigint IDENTITY ( 0,1 ) ,
	LoginRoleID         tinyint  NOT NULL ,
	LoginName			nvarchar(64)  NOT NULL ,
	[Password]			nvarchar(128)  NOT NULL ,
	Email				nvarchar(64)  NOT NULL ,
	IsConfirmed         bit  NOT NULL ,
	ScreenName			nvarchar(64) NULL ,
	ShowScreenName		BIT  NOT NULL,
	LoginView			AS (case when isnull(patindex('%[^ ]%',[ScreenName]),(0))>(0) AND [ShowScreenName]=(1) then [ScreenName] else [LoginName] end) PERSISTED,	
	CONSTRAINT PK_Logins PRIMARY KEY  CLUSTERED (LoginID ASC),
	CONSTRAINT FK_Logins_LoginRoles FOREIGN KEY (LoginRoleID) REFERENCES dbo.LoginRoles(LoginRoleID)
)
GO

ALTER TABLE [dbo].[Logins] CHECK CONSTRAINT [FK_Logins_LoginRoles]
GO
ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_IsConfirmed]  DEFAULT ((0)) FOR [IsConfirmed]
GO
ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_ShowScreenName]  DEFAULT ((0)) FOR [ShowScreenName]
GO


CREATE UNIQUE NONCLUSTERED INDEX [IU_Logins_LoginName] ON [dbo].[Logins]
(
	[LoginName]
)
GO

/*
CREATE UNIQUE NONCLUSTERED INDEX [IU_Logins_Email] ON [dbo].[Logins]
(
	[Email]
)
GO
*/
--==================================================================


INSERT INTO dbo.Logins(
	LoginRoleID,
	LoginName,
	[Password],
	Email,
	ScreenName,	
	IsConfirmed,
	ShowScreenName
)
VALUES(1,'admin','1','noteplot@bk.ru', 'admin', 1,0);
GO

/*
INSERT INTO dbo.Logins(
	LoginRoleID,
	LoginName,
	[Password],
	Email,
	ScreenName,	
	IsConfirmed,
	ShowScreenName
)
VALUES(1,'noteplot','1','noteplot@bk.ru', '���� ������', 1,0);
GO
*/


	


