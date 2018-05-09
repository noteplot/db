SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ParamTypes
( 
	ParamTypeID          tinyint  NOT NULL ,
	ParamTypeName        nvarchar(32)  NOT NULL ,
	CONSTRAINT PK_ParamTypes PRIMARY KEY  CLUSTERED (ParamTypeID ASC)
)
go


INSERT INTO dbo.ParamTypes(ParamTypeID,ParamTypeName)
VALUES
	(0,'�������'),(1,'���������'),(2,'��������')
go	
	