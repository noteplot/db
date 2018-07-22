SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ResourceCounts
( 
	LoginID              bigint  NOT NULL ,
	ResourceLimitID      integer  NOT NULL ,
	Value                integer  NOT NULL ,
	CONSTRAINT PK_ResourceCounts PRIMARY KEY  CLUSTERED (LoginID ASC,ResourceLimitID ASC),
	CONSTRAINT FK_ResourceCounts_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID),
	CONSTRAINT FK_ResourceCounts_ResourceLimits FOREIGN KEY (ResourceLimitID) REFERENCES dbo.ResourceLimits(ResourceLimitID)
)
go

ALTER TABLE dbo.ResourceCounts CHECK CONSTRAINT [FK_ResourceCounts_Logins]
GO

ALTER TABLE dbo.ResourceCounts CHECK CONSTRAINT [FK_ResourceCounts_ResourceLimits]
GO

ALTER TABLE dbo.ResourceCounts
	ADD CONSTRAINT DF_ResourceCounts
		 DEFAULT  0 FOR Value
go


