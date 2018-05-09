SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Monitorings
( 
	MonitoringID         bigint  NOT NULL IDENTITY (1,1),
	MonitorID            bigint  NOT NULL ,
	MonitoringDate       DATETIME2(0)  NOT NULL ,
	MonitoringComment    nvarchar(255)  NULL ,
	CreationDateUTC      datetime  NOT NULL ,
	ModifiedDateUTC      datetime  NOT NULL ,
	CONSTRAINT PK_Monitorings PRIMARY KEY  CLUSTERED (MonitoringID ASC),
	CONSTRAINT FK_Monitorings_Monitors FOREIGN KEY (MonitorID) REFERENCES dbo.Monitors(MonitorID),
)
go

CREATE UNIQUE NONCLUSTERED INDEX IU_Monitoring_MonitorDate ON dbo.Monitorings
( 
	MonitorID             ASC,
	MonitoringDate        DESC
)
go

ALTER TABLE dbo.Monitorings
	ADD CONSTRAINT DF_CurrentUTCDate_MonitoringCreationDate
		 DEFAULT  GETUTCDATE() FOR CreationDateUTC
go

ALTER TABLE dbo.Monitorings
	ADD CONSTRAINT DF_CurrentUTCDate_MonitoringModifiedDate
		 DEFAULT  GETUTCDATE() FOR ModifiedDateUTC
go


