
CREATE TABLE dbo.Languages
( 
	LanguageID           integer  NOT NULL ,
	LanguageCode         nvarchar(20)  NOT NULL ,
	LangugeName          nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_язык_сайта PRIMARY KEY  CLUSTERED (LanguageID ASC)
)
go




CREATE TABLE dbo.UnitGroups
( 
	UnitGroupID          bigint IDENTITY ( 1,1 ) ,
	UnitGroupCode        nvarchar(20)  NOT NULL ,
	LoginID              bigint  NULL ,
	UnitGroupShortName   nvarchar(64)  NOT NULL ,
	UnitGroupName        nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_UnitGroups PRIMARY KEY  CLUSTERED (UnitGroupID ASC),
	CONSTRAINT FK_UnitGroups_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE TABLE dbo.Units
( 
	UnitID               bigint  NOT NULL ,
	UnitCode             nvarchar(20)  NOT NULL ,
	UnitGroupID          bigint  NOT NULL ,
	LoginID              bigint  NULL ,
	UnitShortName        nvarchar(64)  NOT NULL ,
	UnitName             nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_≈д_изм PRIMARY KEY  CLUSTERED (UnitID ASC),
	CONSTRAINT FK_Units_UnitGroups FOREIGN KEY (UnitGroupID) REFERENCES dbo.UnitGroups(UnitGroupID),
CONSTRAINT FK_Units_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE TABLE dbo.Packets
( 
	PacketID             bigint  NOT NULL ,
	LoginID              bigint  NOT NULL ,
	PacketCode           nvarchar(20)  NOT NULL ,
	PacketShortName      nvarchar(64)  NOT NULL ,
	PacketName           nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_Packets PRIMARY KEY  CLUSTERED (PacketID ASC),
	CONSTRAINT FK_Packets_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE TABLE dbo.Monitors
( 
	MonitorID            bigint IDENTITY ( 1,1 ) ,
	LoginID              bigint  NULL ,
	MonitorCode          nvarchar(20)  NOT NULL ,
	MonitorShortName     nvarchar(64)  NOT NULL ,
	MonitorName          nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_Monitors PRIMARY KEY  CLUSTERED (MonitorID ASC),
	CONSTRAINT FK_Monitors_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE TABLE dbo.ParamValueTypes
( 
	ParamValueTypeID     tinyint  NOT NULL ,
	IsNumeric            bit  NOT NULL ,
	Scale                tinyint  NOT NULL ,
	ParamValueTypeCode   nvarchar(20)  NOT NULL ,
	ParamValueTypeShortName nvarchar(64)  NOT NULL ,
	ParamValueTypeName   nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_ParamValueTypes PRIMARY KEY  CLUSTERED (ParamValueTypeID ASC)
)
go



CREATE TABLE dbo.ParamGroups
( 
	ParamGroupID         bigint IDENTITY ( 1,1 ) ,
	LoginID              bigint  NULL ,
	ParamGroupCode       nvarchar(20)  NOT NULL ,
	ParamGroupShortName  varchar(64)  NOT NULL ,
	ParamGroupName       nvarchar(64)  NOT NULL ,
	CONSTRAINT PK_ParamGroups PRIMARY KEY  CLUSTERED (ParamGroupID ASC),
	CONSTRAINT FK_ParamGroups_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go



CREATE TABLE dbo.Params
( 
	ParamID              bigint IDENTITY ( 1,1 ) ,
	Active               bit  NOT NULL ,
	ParamValueMAX        decimal(28,6)  NULL ,
	ParamValueMIN        decimal(28,6)  NULL ,
	ParamGroupID         bigint  NOT NULL ,
	ParamValueTypeID     tinyint  NOT NULL ,
	LoginID              bigint  NULL ,
	ParamCode            nvarchar(20)  NOT NULL ,
	ParamUnitID          bigint  NOT NULL ,
	ParamShortName       nvarchar(64)  NOT NULL ,
	ParamName            nvarchar(128)  NOT NULL ,
	CONSTRAINT PK_Params PRIMARY KEY  CLUSTERED (ParamID ASC),
	CONSTRAINT FK_Params_ParamGroups FOREIGN KEY (ParamGroupID) REFERENCES dbo.ParamGroups(ParamGroupID),
CONSTRAINT FK_Params_ParamValueTypes FOREIGN KEY (ParamValueTypeID) REFERENCES dbo.ParamValueTypes(ParamValueTypeID),
CONSTRAINT FK_Params_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID),
CONSTRAINT FK_Params_Units FOREIGN KEY (ParamUnitID) REFERENCES dbo.Units(UnitID)
)
go


