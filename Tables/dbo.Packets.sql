SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Packets
( 
	PacketID             bigint  NOT NULL ,
	PacketShortName      nvarchar(24)  NOT NULL ,
	PacketName           nvarchar(48)  NOT NULL ,
	LoginID              bigint  NOT NULL ,
	CONSTRAINT PK_Packets PRIMARY KEY  CLUSTERED (PacketID ASC),
	CONSTRAINT FK_Packets_Parameters FOREIGN KEY (PacketID) REFERENCES dbo.Parameters(ParameterID),
	CONSTRAINT FK_Packets_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
GO

ALTER TABLE [dbo].[Packets] CHECK CONSTRAINT [FK_Packets_Parameters]
GO

ALTER TABLE [dbo].[Packets] CHECK CONSTRAINT [FK_Packets_Logins]
GO

CREATE UNIQUE NONCLUSTERED INDEX IU_Packets_Login_ShortName ON dbo.Packets
( 
	LoginID ASC,
	PacketShortName ASC	
)
GO


