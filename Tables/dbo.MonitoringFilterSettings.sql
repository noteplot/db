SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.MonitoringFilterSettings
( 
	Tops                 integer  NOT NULL ,
	Days                 integer  NOT NULL 
)
go

INSERT INTO dbo.MonitoringFilterSettings(Tops,Days)
VALUES(10,30)
go