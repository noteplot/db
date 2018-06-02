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
(1,'D0','Целое число','Целое число',1,0,19),
(2,'D2','Десятичное число с точностью 2 знака после запятой ','Десятичное число с точностью 2 знака после запятой',1,2,19),
(3,'D3','Десятичное число с точностью 3 знака после запятой ','Десятичное число с точностью 3 знака после запятой',1,3,19),	
(4,'D4','Десятичное число с точностью 4 знака после запятой ','Десятичное число с точностью 4 знака после запятой',1,4,19),
(5,'D5','Десятичное число с точностью 5 знаков после запятой ','Десятичное число с точностью 5 знаков после запятой',1,5,19),
(6,'D6','Десятичное число с точностью 6 знаков после запятой ','Десятичное число с точностью 6 знаков после запятой',1,6,19)
/*
,
(21,'S','Строка','Строка',0,0,128),
(22,'T','Текст','Текст',0,0,256)
*/

go	
	