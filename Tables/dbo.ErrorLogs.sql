SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ErrorLogs(
	ErrorLogID		int identity(1,1)	not null,
	ErrorLogDt		datetime2(3)		not null,
	ProcedureName	nvarchar(128)		null,
	LoginID			bigint not null,
	ErrorNumber		int null,
	ErrorSeverity	int null,
	ErrorState		int null,
	ErrorLine		int null, 
	ErrorProcedure	nvarchar(128)  null,
	ErrorMessage	nvarchar(4000) null,
	CONSTRAINT [PK_ErrorLogs]  PRIMARY KEY CLUSTERED (ErrorLogID)
)
GO

ALTER TABLE dbo.ErrorLogs ADD  CONSTRAINT [DF_ErrorLogs_ErrorLogDt]  DEFAULT (getdate()) FOR [ErrorLogDt]
GO

CREATE NONCLUSTERED INDEX [IX_ERRORLOGS_LOGDT_LOGINID] ON [dbo].[ErrorLogs] 
(
	ErrorLogDt,
	LoginID
)
GO

