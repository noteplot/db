SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.UnitGroups
( 
	UnitGroupID          bigint IDENTITY ( 1,1 ) ,
	UnitGroupShortName   nvarchar(24)  NOT NULL ,
	UnitGroupName        nvarchar(48)  NOT NULL ,
	LoginID              bigint  NOT NULL ,
	CONSTRAINT PK_UnitGroups PRIMARY KEY  CLUSTERED (UnitGroupID ASC),
	CONSTRAINT FK_UnitGroups_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go

ALTER TABLE [dbo].[UnitGroups] CHECK CONSTRAINT [FK_UnitGroups_Logins]
GO
/*
НУЛЕВОЙ ЛОГИН!!!

UPDATE dbo.UnitGroups
SET LoginID = 0

*/


SET IDENTITY_INSERT UnitGroups ON
GO
INSERT INTO UnitGroups (UnitGroupID, UnitGroupName, UnitGroupShortName) VALUES (1, N'Общие‎‎', N'Общие‎‎')
INSERT INTO UnitGroups (UnitGroupID, UnitGroupName, UnitGroupShortName) VALUES (2, N'Время‎‎', N'Время‎‎')
INSERT INTO UnitGroups (UnitGroupID, UnitGroupName, UnitGroupShortName) VALUES (3, N'Вязкость', N'Вязкость')
INSERT INTO UnitGroups (UnitGroupID, UnitGroupName, UnitGroupShortName) VALUES (4, N'Давление', N'Давление')

SET IDENTITY_INSERT UnitGroups OFF
GO




