SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.LoginResourceLimits
( 
	LoginID              bigint  NOT NULL ,
	ResourceLimitID      integer  NOT NULL ,
	ResourceLimitValue   integer  NOT NULL ,
	CONSTRAINT PK_LoginResourceLimits PRIMARY KEY  CLUSTERED (LoginID ASC,ResourceLimitID ASC),
	CONSTRAINT FK_LoginResourceLimits_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID),
CONSTRAINT FK_LoginResourceLimits_ResourceLimits FOREIGN KEY (ResourceLimitID) REFERENCES dbo.ResourceLimits(ResourceLimitID)
)
go

