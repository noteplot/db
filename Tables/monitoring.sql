CREATE TABLE dbo.MonitorParams
( 
	MonitorParamID       bigint IDENTITY ( 1,1 ) ,
	MonitorID            bigint  NOT NULL ,
	ParameterID          bigint  NOT NULL ,
	MonitorParamPosition smallint  NOT NULL ,
	Active               bit  NOT NULL ,
	LoginID              bigint  NOT NULL ,
	CONSTRAINT PK_MonitorParams PRIMARY KEY  CLUSTERED (MonitorParamID ASC),
	CONSTRAINT FK_MonitorParams_Monitors FOREIGN KEY (MonitorID) REFERENCES dbo.Monitors(MonitorID),
CONSTRAINT FK_MonitorParams_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID),
CONSTRAINT FK_MonitorParams_Parameters FOREIGN KEY (ParameterID) REFERENCES dbo.Parameters(ParameterID)
)
go



CREATE TABLE dbo.MonitorTotalParamValues
( 
	MonitorParamID       bigint  NOT NULL ,
	MonitorParamValue    decimal(28,6)  NOT NULL ,
	LoginID              bigint  NULL ,
	CONSTRAINT PK_MonitorTotalParamValues PRIMARY KEY  CLUSTERED (MonitorParamID ASC),
	CONSTRAINT FK_MonitorTotalParamValues_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
CONSTRAINT FK_MonitorTotalParamValues_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go

CREATE TABLE dbo.MonitoringParams
( 
	MonitoringParamID    bigint IDENTITY ( 1,1 ) ,
	MonitoringID         bigint  NOT NULL ,
	MonitorParamID       bigint  NOT NULL ,
	ParamValueTypeID     tinyint  NOT NULL ,
	DateInsert           datetime  NOT NULL ,
	DateEdit             datetime  NOT NULL ,
	CONSTRAINT PK_MonitoringParams PRIMARY KEY  CLUSTERED (MonitoringParamID ASC),
	CONSTRAINT FK_MonitoringParams_Monitorings FOREIGN KEY (MonitoringID) REFERENCES dbo.Monitorings(MonitoringID),
CONSTRAINT FK_MonitoringParams_MonitorParams FOREIGN KEY (MonitorParamID) REFERENCES dbo.MonitorParams(MonitorParamID),
CONSTRAINT FK_MonitoringParams_ParamValueTypes FOREIGN KEY (ParamValueTypeID) REFERENCES dbo.ParamValueTypes(ParamValueTypeID)
)
go



CREATE TABLE dbo.MonitoringParamStringValues
( 
	MonitoringParamID    bigint  NOT NULL ,
	MonitoringParamValue varchar(255)  NOT NULL ,
	CONSTRAINT PK_MonitoringParamStringValues PRIMARY KEY  CLUSTERED (MonitoringParamID ASC),
	CONSTRAINT FK_MonitoringParamStringValues_MonitoringParams FOREIGN KEY (MonitoringParamID) REFERENCES dbo.MonitoringParams(MonitoringParamID)
)
go



CREATE TABLE dbo.MonitoringParamValues
( 
	MonitoringParamID    bigint  NOT NULL ,
	MonitoringParamValue decimal(28,6)  NULL ,
	CONSTRAINT PK_MonitoringParamNumberValues PRIMARY KEY  CLUSTERED (MonitoringParamID ASC),
	CONSTRAINT FK_MonitoringParamValues_MonitoringParams FOREIGN KEY (MonitoringParamID) REFERENCES dbo.MonitoringParams(MonitoringParamID)
)
go

