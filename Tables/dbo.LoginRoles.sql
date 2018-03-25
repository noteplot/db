CREATE TABLE dbo.LoginRoles
( 
	LoginRoleID          tinyint  NOT NULL ,
	LoginRoleCode        nvarchar(20)  NOT NULL ,
	LoginRoleShortName   nvarchar(64)  NOT NULL ,
	LoginRoleName        nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_LoginRoles PRIMARY KEY  CLUSTERED (LoginRoleID ASC)
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