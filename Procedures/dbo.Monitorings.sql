CREATE TABLE dbo.Monitorings
( 
	MonitoringID         bigint  NOT NULL ,
	MonitorID            bigint  NOT NULL ,
	MonitoringDate       DATETIME2(0)  NOT NULL ,
	MonitoringComment    nvarchar(255)  NULL ,
	LoginID              bigint  NOT NULL ,
	CreationDate         datetime  NOT NULL ,
	ModifiedDate         datetime  NOT NULL ,
	CONSTRAINT PK_Monitorings PRIMARY KEY  CLUSTERED (MonitoringID ASC),
	CONSTRAINT FK_Monitorings_Monitors FOREIGN KEY (MonitorID) REFERENCES dbo.Monitors(MonitorID),
CONSTRAINT FK_Monitorings_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE UNIQUE NONCLUSTERED INDEX IU_Monitoring_MonitorDate ON dbo.Monitorings
( 
	MonitorID             ASC,
	MonitoringDate        ASC
)
go



ALTER TABLE dbo.Monitorings
	ADD CONSTRAINT DF_CurrentUTCDate_MonitoringCreationDate
		 DEFAULT  GETUTCDATE() FOR CreationDate
go




ALTER TABLE dbo.Monitorings
	ADD CONSTRAINT DF_CurrentUTCDate_MonitoringModifiedDate
		 DEFAULT  GETUTCDATE() FOR ModifiedDate
go


