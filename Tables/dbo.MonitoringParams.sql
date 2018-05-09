SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.MonitoringParams
( 
	MonitoringParamID    bigint IDENTITY ( 1,1 ) ,
	MonitoringID         bigint  NOT NULL ,
	MonitorParamID       bigint  NOT NULL ,
	ParamID              bigint  NOT NULL ,
	ParamValue           decimal(28,6)  NOT NULL ,
	CreationDateUTC      datetime  NOT NULL ,
	ModifiedDateUTC      datetime  NOT NULL ,
	CONSTRAINT PK_MonitoringParams PRIMARY KEY  CLUSTERED (MonitoringParamID ASC),
	CONSTRAINT FK_MonitoringParams_Monitorings FOREIGN KEY (MonitoringID) REFERENCES dbo.Monitorings(MonitoringID),
	CONSTRAINT FK_MonitoringParams_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
	CONSTRAINT FK_MonitoringParams_Params FOREIGN KEY (ParamID) REFERENCES dbo.Params(ParamID)
)
go


ALTER TABLE dbo.MonitoringParams
	ADD CONSTRAINT DF_MonitoringParams_CreationDate
		 DEFAULT  GETUTCDATE() FOR CreationDateUTC
go

ALTER TABLE dbo.MonitoringParams
	ADD CONSTRAINT DF_MonitoringParams_ModifiedDate
		 DEFAULT  GETUTCDATE() FOR ModifiedDateUTC
go


