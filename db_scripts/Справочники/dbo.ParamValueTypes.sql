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
(1,'D0','����� �����','����� �����',1,0,26),
(2,'D2','���������� ����� � ��������� 2 ����� ����� ������� ','���������� ����� � ��������� 2 ����� ����� �������',1,2,26),
(3,'D3','���������� ����� � ��������� 3 ����� ����� ������� ','���������� ����� � ��������� 3 ����� ����� �������',1,3,26),	
(4,'D4','���������� ����� � ��������� 4 ����� ����� ������� ','���������� ����� � ��������� 4 ����� ����� �������',1,4,26),
(5,'D5','���������� ����� � ��������� 5 ������ ����� ������� ','���������� ����� � ��������� 5 ������ ����� �������',1,5,26),
(6,'D6','���������� ����� � ��������� 6 ������ ����� ������� ','���������� ����� � ��������� 6 ������ ����� �������',1,6,26),

(21,'S','������','������',0,0,128),
(22,'T','�����','�����',0,0,256)


go	
	