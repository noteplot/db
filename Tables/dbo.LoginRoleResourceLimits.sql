SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.LoginRoleResourceLimits
( 
	LoginRoleID          tinyint  NOT NULL ,
	ResourceLimitID      integer  NOT NULL ,
	ResourceLimitValue   integer  NOT NULL ,
	CONSTRAINT PK_ResourceLimitRoles PRIMARY KEY  CLUSTERED (LoginRoleID ASC,ResourceLimitID ASC),
	CONSTRAINT FK_ResourceLimitRoles_LoginRoles FOREIGN KEY (LoginRoleID) REFERENCES dbo.LoginRoles(LoginRoleID),
CONSTRAINT FK_LoginRoleResourceLimits_ResourceLimits FOREIGN KEY (ResourceLimitID) REFERENCES dbo.ResourceLimits(ResourceLimitID)
)
go

INSERT INTO dbo.LoginRoleResourceLimits(
	LoginRoleID,          
	ResourceLimitID,      
	ResourceLimitValue   	
)
VALUES
(100,1,1000),
(100,2,1000),
(100,3,100000)
go	