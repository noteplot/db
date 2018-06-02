SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.LoginRoles
( 
	LoginRoleID          tinyint  NOT NULL ,
	LoginRoleCode        nvarchar(20)  NOT NULL ,
	LoginRoleShortName   nvarchar(64)  NOT NULL ,
	LoginRoleName        nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_LoginRoles PRIMARY KEY CLUSTERED (LoginRoleID ASC)
)
go

INSERT INTO dbo.LoginRoles(
	LoginRoleID,          
	LoginRoleCode,        
	LoginRoleShortName,   
	LoginRoleName        
)
VALUES
(1,'DEMO','�����','�����'),
(2,'USER','������������','������������'),
(80,'MODERATOR','���������','���������'),
(100,'ADMIN','�������������','�������������')	
go