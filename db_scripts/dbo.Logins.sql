CREATE TABLE dbo.Logins
( 
	LoginID             bigint IDENTITY ( 1,1 ) ,
	LoginRoleID         tinyint  NOT NULL ,
	LoginName			nvarchar(32)  NOT NULL ,
	[Password]			nvarchar(128)  NOT NULL ,
	Email				nvarchar(64)  NOT NULL ,
	IsConfirmed         bit  NOT NULL ,
	Name				nvarchar(64) NULL ,
	ShowName			BIT  NOT NULL,
	LoginView			AS (case when[ShowName]= (0) OR [Name] IS NULL then [LoginName] else [Name] end) PERSISTED,	
	CONSTRAINT PK_Logins PRIMARY KEY  CLUSTERED (LoginID ASC),
	CONSTRAINT FK_Logins_LoginRoles FOREIGN KEY (LoginRoleID) REFERENCES dbo.LoginRoles(LoginRoleID)
)
GO

ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_IsConfirmed]  DEFAULT ((0)) FOR [IsConfirmed]
GO
ALTER TABLE [dbo].[Logins] ADD  CONSTRAINT [DF_Logins_ShowNick]  DEFAULT ((0)) FOR [ShowName]
GO


INSERT INTO dbo.Logins(
	LoginRoleID,
	LoginName,
	[Password],
	Email,
	Name,	
	IsConfirmed,
	ShowName
)
VALUES(1,'andranick','1','@andranick@bk.ru', 'Андрей Багиров', 1,0);
GO

	


