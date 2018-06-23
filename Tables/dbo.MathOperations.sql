SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.MathOperations
( 
	MathOperationID      tinyint  NOT NULL ,
	MathOperationShortName varchar(10)  NOT NULL ,
	MathOperationName    varchar(30)  NOT NULL ,
	CONSTRAINT PK_ParamActions PRIMARY KEY  CLUSTERED (MathOperationID ASC)
)
GO

INSERT INTO dbo.MathOperations(
	MathOperationID,
	MathOperationShortName,
	MathOperationName	
)
VALUES
(1,'+','сложение'),
(2,'-','вычитание'),
(3,'*','умножение'),
(4,'*','деление')

GO
