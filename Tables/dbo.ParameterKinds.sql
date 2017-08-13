
CREATE TABLE dbo.ParameterKinds
( 
	ParameterKindID      tinyint  NOT NULL ,
	Name                 nvarchar(24)  NOT NULL ,
	CONSTRAINT PK_ParameterKinds PRIMARY KEY  CLUSTERED (ParameterKindID ASC)
)
go


--ALTER TABLE dbo.ParameterKinds
--	ADD CONSTRAINT DF_ParameterKinds
--		 DEFAULT  0 FOR ParameterKindID
--go

INSERT INTO dbo.ParameterKinds (ParameterKindID, Name)
VALUES	
	(0,'Параметр'),(1,'Пакет')
go	