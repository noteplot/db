
CREATE TABLE dbo.MonitoringFilterSettings
( 
	Tops                 integer  NOT NULL ,
	Days                 integer  NOT NULL 
)
go

INSERT INTO dbo.MonitoringFilterSettings(Tops,Days)
VALUES(10,30)
go