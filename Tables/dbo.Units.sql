CREATE TABLE dbo.Units
( 
	UnitID               bigint IDENTITY ( 1,1 ) ,
	UnitShortName        nvarchar(16)  NOT NULL ,
	UnitName             nvarchar(32)  NOT NULL ,
	UnitGroupID          bigint  NOT NULL ,
	LoginID              bigint  NULL ,
	CONSTRAINT PK_Units PRIMARY KEY  CLUSTERED (UnitID ASC),
	CONSTRAINT FK_Units_UnitGroups FOREIGN KEY (UnitGroupID) REFERENCES dbo.UnitGroups(UnitGroupID),
CONSTRAINT FK_Units_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go

SET IDENTITY_INSERT Units ON
GO
-- �����
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (1, 1, N'��.', N'�����')

-- �����

INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (2, 2, N'������������� ���', N'��. ���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (3, 2, N'���', N'���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (4, 2, N'�������', N'�������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (5, 2, N'�������', N'�������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (6, 2, N'���', N'���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (7, 2, N'������', N'������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (8, 2, N'�����������', N'�����������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (9, 2, N'������', N'������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (10, 2, N'���', N'���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (11, 2, N'�������', N'�������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (12, 2, N'�����', N'�����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (13, 2, N'������� ����', N'������� ����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (14, 2, N'������', N'������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (15, 2, N'������', N'������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (16, 2, N'���������', N'���������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (17, 2, N'�����', N'�����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (18, 2, N'���', N'���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (19, 2, N'��������-���', N'��������-���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (20, 2, N'���', N'���')
GO

-- ��������
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (21, 3, N'������ �������', N'������ �������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (22, 3, N'����', N'����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (23, 3, N'�����', N'�����')
GO

--��������
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (24, 4, N'���������', N'���������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (25, 4, N'���', N'���')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (26, 4, N'�����', N'�����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (27, 4, N'���� �������� ������', N'���� ���. ��.')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (28, 4, N'���� �������� ������', N'���� ��. ������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (29, 4, N'��������� �������� ������', N'�� ���. ������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (30, 4, N'��������� �������� ������', N'�� ��. ������')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (31, 4, N'�������', N'�������', N'��')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (32, 4, N'����������� ��������', N'�����.����.')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (33, 4, N'�����', N'�����')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (34, 4, N'���� �� ���������� ����', N'���� �� ��.����')
GO
SET IDENTITY_INSERT Units OFF
GO