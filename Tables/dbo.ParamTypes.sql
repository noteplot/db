
CREATE TABLE dbo.ParamTypes
( 
	ParamTypeID          tinyint  NOT NULL ,
	ParamTypeName        nvarchar(32)  NOT NULL ,
	CONSTRAINT PK_ParamTypes PRIMARY KEY  CLUSTERED (ParamTypeID ASC)
)
go


INSERT INTO dbo.ParamTypes(ParamTypeID,ParamTypeName)
VALUES
	(0,'Простой'),(1,'Расчетный'),(2,'Итоговый')
go	
	