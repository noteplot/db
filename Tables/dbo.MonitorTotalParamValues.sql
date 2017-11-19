
CREATE TABLE dbo.MonitorTotalParamValues
( 
	MonitorParamID       bigint  NOT NULL ,
	MonitorParamValue    decimal(28,6)  NULL ,
	CONSTRAINT PK_MonitorTotalParamValues PRIMARY KEY  CLUSTERED (MonitorParamID ASC),
	CONSTRAINT FK_MonitorTotalParamValues_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
)
go


