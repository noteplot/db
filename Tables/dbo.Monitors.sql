SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

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
GO


ALTER TABLE dbo.Monitors
	ADD CONSTRAINT DF_Monitors_Active
		 DEFAULT  1 FOR Active
GO

ALTER TABLE [dbo].[Monitors] CHECK CONSTRAINT [FK_Monitors_Logins]
GO
/*
CREATE NONCLUSTERED INDEX IX_Monitors_LoginID ON dbo.Monitors
( 
	LoginID ASC
)
GO
*/
CREATE UNIQUE NONCLUSTERED INDEX [IU_Monitors_LoginID_ShortName] ON [dbo].[Monitors]
(
	[LoginID],
	[MonitorShortName]
)
GO

