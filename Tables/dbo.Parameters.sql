SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Parameters
( 
	ParameterID          bigint IDENTITY ( 1,1 ) ,
	ParameterKindID      tinyint  NOT NULL ,
	ParameterGroupID     bigint  NOT NULL ,
	Active               bit  NOT NULL ,
	CONSTRAINT PK_Parameters PRIMARY KEY  CLUSTERED (ParameterID ASC)
)
GO

ALTER TABLE dbo.Parameters
	ADD CONSTRAINT DF_Parameter_Active
		 DEFAULT  1 FOR Active
GO

ALTER TABLE dbo.Parameters
	ADD CONSTRAINT DF_Paremeters_ParameterKindID
		 DEFAULT  0 FOR ParameterKindID
GO

ALTER TABLE dbo.Parameters
	ADD CONSTRAINT FK_Parameters_ParameterKinds FOREIGN KEY (ParameterKindID) REFERENCES dbo.ParameterKinds(ParameterKindID)

ALTER TABLE [dbo].[Parameters] CHECK CONSTRAINT [FK_Parameters_ParameterKinds]
GO

ALTER TABLE dbo.Parameters
	ADD CONSTRAINT FK_Parameters_ParameterGroups FOREIGN KEY (ParameterGroupID) REFERENCES dbo.ParameterGroups(ParameterGroupID)
GO

ALTER TABLE [dbo].[Parameters] CHECK CONSTRAINT [FK_Parameters_ParameterGroups]
GO
