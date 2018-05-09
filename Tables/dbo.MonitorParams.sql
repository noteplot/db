SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.MonitorParams
( 
	MonitorParamID       bigint IDENTITY ( 1,1 ) ,
	MonitorID            bigint  NOT NULL ,
	ParameterID          bigint  NOT NULL ,
	MonitorParamPosition smallint  NOT NULL ,
	Active               bit  NOT NULL ,
	CONSTRAINT PK_MonitorParams PRIMARY KEY  CLUSTERED (MonitorParamID ASC),
	CONSTRAINT FK_MonitorParams_Monitors FOREIGN KEY (MonitorID) REFERENCES dbo.Monitors(MonitorID),
CONSTRAINT FK_MonitorParams_Parameters FOREIGN KEY (ParameterID) REFERENCES dbo.Parameters(ParameterID)
)
go


ALTER TABLE dbo.MonitorParams
	ADD CONSTRAINT DF_MonitorParams_Position
		 DEFAULT  1 FOR MonitorParamPosition
go

ALTER TABLE dbo.MonitorParams
	ADD CONSTRAINT DF_MonitorParams_Active
		 DEFAULT  1 FOR Active
go

CREATE NONCLUSTERED INDEX [IX_MonitorParams_MonitorID] ON [dbo].[MonitorParams]
(
	[MonitorID] ASC
)
GO

