SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.PacketParams
( 
	PacketParamID        bigint  NOT NULL IDENTITY(1,1),
	PacketID             bigint  NOT NULL ,
	ParamID              bigint  NOT NULL ,
	PacketParamPosition  smallint  NOT NULL ,
	Active               bit  NOT NULL ,
	CONSTRAINT PK_PacketParams PRIMARY KEY  CLUSTERED (PacketParamID ASC),
	CONSTRAINT FK_PacketParams_Params FOREIGN KEY (ParamID) REFERENCES dbo.Params(ParamID),
	CONSTRAINT FK_PacketParams_Packets FOREIGN KEY (PacketID) REFERENCES dbo.Packets(PacketID)
)
GO

ALTER TABLE dbo.PacketParams
	ADD CONSTRAINT DF_PacketParams_Active
		 DEFAULT  1 FOR Active
GO

ALTER TABLE [dbo].[PacketParams] CHECK CONSTRAINT [FK_PacketParams_Params]
GO

ALTER TABLE [dbo].[PacketParams] CHECK CONSTRAINT [FK_PacketParams_Packets]
GO

CREATE UNIQUE NONCLUSTERED INDEX IU_PacketParams_PacketID_ParamID ON dbo.PacketParams
( 
	PacketID ASC,
	ParamID ASC
)
GO

/*
CREATE NONCLUSTERED INDEX IX_PacketParams_ParamID ON dbo.PacketParams
( 
	ParamID               ASC
)
GO
*/


