SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.MonitorTotalParamValues
( 
	MonitorParamID       bigint  NOT NULL ,
	MonitorParamValue    decimal(28,6)  NULL ,
	CONSTRAINT PK_MonitorTotalParamValues PRIMARY KEY  CLUSTERED (MonitorParamID ASC),
	CONSTRAINT FK_MonitorTotalParamValues_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
)
go


