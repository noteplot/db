SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ParamRelations
( 
	ParamRelationID      bigint IDENTITY ( 1,1 ) ,
	PrimaryParamID       bigint  NOT NULL ,
	SecondaryParamID     bigint  NOT NULL ,
	MathOperationID      tinyint  NOT NULL ,
	ParamRelationPosition smallint  NOT NULL ,
	CONSTRAINT PK_ParamRelations PRIMARY KEY  CLUSTERED (ParamRelationID ASC),
	CONSTRAINT FK_ParamRelations_MathOperations FOREIGN KEY (MathOperationID) REFERENCES dbo.MathOperations(MathOperationID),
	CONSTRAINT FK_ParamRelations_SecondaryParams FOREIGN KEY (SecondaryParamID) REFERENCES dbo.Params(ParamID),
	CONSTRAINT FK_ParamRelations_PrimaryParams FOREIGN KEY (PrimaryParamID) REFERENCES dbo.Params(ParamID)
)
go

ALTER TABLE [dbo].[ParamRelations] CHECK CONSTRAINT [FK_ParamRelations_MathOperations]
GO

ALTER TABLE [dbo].[ParamRelations] CHECK CONSTRAINT [FK_ParamRelations_SecondaryParams]
GO

ALTER TABLE [dbo].[ParamRelations] CHECK CONSTRAINT [FK_ParamRelations_PrimaryParams]
GO


CREATE UNIQUE NONCLUSTERED INDEX IU_ParamRelations_Primary_Secondary ON dbo.ParamRelations
( 
	PrimaryParamID        ASC,
	SecondaryParamID      ASC
)
go



CREATE NONCLUSTERED INDEX IX_ParamRelations_Secondary ON dbo.ParamRelations
( 
	SecondaryParamID      ASC
)
go



ALTER TABLE dbo.ParamRelations
	ADD CONSTRAINT DF_ParamRelations_Position
		 DEFAULT  1 FOR ParamRelationPosition
go


