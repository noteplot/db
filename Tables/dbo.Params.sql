SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Params
( 
	ParamID              bigint  NOT NULL ,
	ParamShortName       nvarchar(24)  NOT NULL ,
	ParamName            nvarchar(48)  NOT NULL ,
	ParamUnitID          bigint  NOT NULL ,
	ParamValueTypeID     tinyint  NOT NULL ,
	ParamTypeID          tinyint  NOT NULL ,
	ParamValueMAX        decimal(28,6)  NULL ,
	ParamValueMIN        decimal(28,6)  NULL ,
	LoginID              bigint  NOT NULL ,
	CONSTRAINT PK_Params PRIMARY KEY  CLUSTERED (ParamID ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX IU_Params_Login_ShortName ON dbo.Params
( 
	LoginID               ASC,
	ParamShortName        ASC
)
go

ALTER TABLE dbo.Params
	ADD CONSTRAINT FK_Params_ParamValueTypes FOREIGN KEY (ParamValueTypeID) REFERENCES dbo.ParamValueTypes(ParamValueTypeID)
GO

ALTER TABLE [dbo].[Params] CHECK CONSTRAINT [FK_Params_ParamValueTypes]
GO

ALTER TABLE dbo.Params
	ADD CONSTRAINT FK_Params_Units FOREIGN KEY (ParamUnitID) REFERENCES dbo.Units(UnitID)
GO

ALTER TABLE [dbo].[Params] CHECK CONSTRAINT [FK_Params_Units]
GO

ALTER TABLE dbo.Params
	ADD CONSTRAINT FK_Params_ParamTypes FOREIGN KEY (ParamTypeID) REFERENCES dbo.ParamTypes(ParamTypeID)
GO

ALTER TABLE [dbo].[Params] CHECK CONSTRAINT [FK_Params_ParamTypes]
GO

ALTER TABLE dbo.Params
	ADD CONSTRAINT FK_Params_Parameters FOREIGN KEY (ParamID) REFERENCES dbo.Parameters(ParameterID)
GO

ALTER TABLE [dbo].[Params] CHECK CONSTRAINT [FK_Params_Parameters]
GO

ALTER TABLE dbo.Params
	ADD CONSTRAINT FK_Params_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
GO

ALTER TABLE [dbo].[Params] CHECK CONSTRAINT [FK_Params_Logins]
GO

