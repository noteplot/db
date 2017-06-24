
CREATE TABLE dbo.LoginRoles
( 
	LoginRoleID          tinyint  NOT NULL ,
	LoginCode            nvarchar(20)  NOT NULL ,
	LoginRoleShortName   nvarchar(64)  NOT NULL ,
	LoginRoleName        nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_LoginRoles PRIMARY KEY  CLUSTERED (LoginRoleID ASC)
)
go

INSERT INTO dbo.LoginRoles
(
	LoginRoleID,
	LoginCode,
	LoginRoleShortName,
	LoginRoleName
)
VALUES
(1, 'ADMIN','ADMIN','������������� ��'),
(2, 'MODERATOR','MODERATOR','��������� ��'),
(3, 'USER','USER','������������ ��')