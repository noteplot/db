CREATE TABLE dbo.UnitGroups
( 
	UnitGroupID          bigint IDENTITY ( 1,1 ) ,
	UnitGroupShortName   nvarchar(24)  NOT NULL ,
	UnitGroupName        nvarchar(48)  NOT NULL ,
	LoginID              bigint  NULL ,
	CONSTRAINT PK_UnitGroups PRIMARY KEY  CLUSTERED (UnitGroupID ASC),
	CONSTRAINT FK_UnitGroups_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go

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




