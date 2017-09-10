
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
(1,'+','��������'),
(2,'-','���������'),
(3,'*','���������')

GO
