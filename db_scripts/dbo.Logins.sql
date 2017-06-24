CREATE TABLE dbo.Logins
( 
	LoginID              bigint IDENTITY ( 1,1 ) ,
	LoginName            nvarchar(64)  NOT NULL ,
	LoginNickName        nvarchar(32)  NULL ,
	LoginPassword        nvarchar(128)  NOT NULL ,
	LoginEmail           nvarchar(64)  NOT NULL ,
	LoginRoleID          tinyint  NOT NULL ,
	IsConfirmed          bit  NOT NULL ,
	ShowNick			 BIT  NOT NULL,
	LoginView			 AS (case when[ShowNick]= (0) OR [LoginNickName] IS NULL then [LoginName] else [LoginNickName] end) PERSISTED,	
	CONSTRAINT PK_Logins PRIMARY KEY  CLUSTERED (LoginID ASC),
	CONSTRAINT FK_Logins_LoginRoles FOREIGN KEY (LoginRoleID) REFERENCES dbo.LoginRoles(LoginRoleID)
)
GO

ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_IsConfirmed]  DEFAULT ((0)) FOR [IsConfirmed]
GO
ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_ShowNick]  DEFAULT ((0)) FOR [ShowNick]
GO


INSERT INTO dbo.Logins(
	LoginName,
	LoginEmail,
	LoginNickName,
	LoginRoleID,
	LoginPassword,
	IsConfirmed,
	ShowNick
)
VALUES('@andranick@bk.ru', '@andranick@bk.ru', 'andranick', 1, '1',1,1);
GO

	


