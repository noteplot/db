SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ResourceLimits
( 
	ResourceLimitID      integer  NOT NULL ,
	ResourceLimitName    nvarchar(255)  NOT NULL ,
	ResourceLimitValue   integer  NOT NULL ,
	CONSTRAINT PK_ResourceLimits PRIMARY KEY  CLUSTERED (ResourceLimitID ASC)
)
go


insert into dbo.ResourceLimits(ResourceLimitID,ResourceLimitName,ResourceLimitValue)
values
(1, '���������� ���������',5),
(2, '����� ���������� ����������',30),
(3,	'���������� �������',5),
(4,	'���������� ���������� ��������� �� ��������',10),
(5,	'���������� ���������� ��������',4),
(6, '���������� ��������� �� ��������',180)
go