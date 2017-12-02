CREATE TABLE dbo.MonitoringParams
( 
	MonitoringParamID    bigint IDENTITY ( 1,1 ) ,
	MonitoringID         bigint  NOT NULL ,
	MonitorParamID       bigint  NOT NULL ,
	ParamID              bigint  NOT NULL ,
	ParamValue           numeric(28,6)  NOT NULL ,
	CreationDate         datetime  NOT NULL ,
	ModifiedDate         datetime  NOT NULL ,
	CONSTRAINT PK_MonitoringParams PRIMARY KEY  CLUSTERED (MonitoringParamID ASC),
	CONSTRAINT FK_MonitoringParams_Monitorings FOREIGN KEY (MonitoringID) REFERENCES dbo.Monitorings(MonitoringID),
	CONSTRAINT FK_MonitoringParams_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
	CONSTRAINT FK_MonitoringParams_Params FOREIGN KEY (ParamID) REFERENCES dbo.Params(ParamID)
)
go



ALTER TABLE dbo.MonitoringParams
	ADD CONSTRAINT DF_MonitoringParams_CreationDate
		 DEFAULT  GETUTCDATE() FOR CreationDate
go




ALTER TABLE dbo.MonitoringParams
	ADD CONSTRAINT DF_MonitoringParams_ModifiedDate
		 DEFAULT  GETUTCDATE() FOR ModifiedDate
go


