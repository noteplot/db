CREATE TABLE dbo.Monitors
( 
	MonitorID            bigint IDENTITY ( 1,1 ) ,
	MonitorShortName     nvarchar(24)  NOT NULL ,
	MonitorName          nvarchar(48)  NOT NULL ,
	Active               bit  NOT NULL ,
	LoginID              bigint  NOT NULL ,
	CONSTRAINT PK_Monitors PRIMARY KEY  CLUSTERED (MonitorID ASC),
	CONSTRAINT FK_Monitors_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



ALTER TABLE dbo.Monitors
	ADD CONSTRAINT DF_Monitors_Active
		 DEFAULT  1 FOR Active
go


