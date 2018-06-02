SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ParamValueTypes
( 
	ParamValueTypeID     tinyint  NOT NULL ,
	ParamValueTypeCode   nvarchar(20)  NOT NULL ,
	ParamValueTypeShortName nvarchar(64)  NOT NULL ,
	ParamValueTypeName   nvarchar(128)  NOT NULL ,
	[IsNumeric]          bit  NOT NULL ,
	Scale                tinyint  NOT NULL ,
	[Precision]          integer  NOT NULL ,
	CONSTRAINT PK_ParamValueTypes PRIMARY KEY  CLUSTERED (ParamValueTypeID ASC)
)
go

ALTER TABLE dbo.ParamValueTypes
	ADD CONSTRAINT DF_ParamValuesTypes_IsNumeric
		 DEFAULT  0 FOR IsNumeric
go

ALTER TABLE dbo.ParamValueTypes
	ADD CONSTRAINT DF_ParamValuesTypes_Scale
		 DEFAULT  0 FOR Scale
go

ALTER TABLE dbo.ParamValueTypes
	ADD CONSTRAINT DF_ParamValuesTypes_Precision
		 DEFAULT  0 FOR Precision
go


INSERT INTO dbo.ParamValueTypes(
	ParamValueTypeID,
	ParamValueTypeCode, 
	ParamValueTypeShortName, 
	ParamValueTypeName,
	[IsNumeric], 
	Scale,
	Precision
)
VALUES
(1,'D0','����� �����','����� �����',1,0,19),
(2,'D2','���������� ����� � ��������� 2 ����� ����� ������� ','���������� ����� � ��������� 2 ����� ����� �������',1,2,19),
(3,'D3','���������� ����� � ��������� 3 ����� ����� ������� ','���������� ����� � ��������� 3 ����� ����� �������',1,3,19),	
(4,'D4','���������� ����� � ��������� 4 ����� ����� ������� ','���������� ����� � ��������� 4 ����� ����� �������',1,4,19),
(5,'D5','���������� ����� � ��������� 5 ������ ����� ������� ','���������� ����� � ��������� 5 ������ ����� �������',1,5,19),
(6,'D6','���������� ����� � ��������� 6 ������ ����� ������� ','���������� ����� � ��������� 6 ������ ����� �������',1,6,19)
/*
,
(21,'S','������','������',0,0,128),
(22,'T','�����','�����',0,0,256)
*/

go	
	