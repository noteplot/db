SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ParameterGroups
( 
	ParameterGroupID     bigint IDENTITY ( 1,1 ) ,
	ParameterGroupShortName nvarchar(24)  NOT NULL ,
	ParameterGroupName   nvarchar(48)  NOT NULL ,
	LoginID              bigint  NULL ,
	CONSTRAINT PK_ParamGroups PRIMARY KEY  CLUSTERED (ParameterGroupID ASC)
)
go



CREATE UNIQUE NONCLUSTERED INDEX IU_ParamGroups_Login_ShortName ON dbo.ParameterGroups
( 
	LoginID               ASC,
	ParameterGroupShortName  ASC
)
go




ALTER TABLE dbo.ParameterGroups
	ADD CONSTRAINT FK_ParameterGroups_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
go

