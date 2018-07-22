SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.ResourceLimits
( 
	ResourceLimitID      integer  NOT NULL ,
	ResourceLimitName    nvarchar(255)  NOT NULL ,
	ResourceLimitValue   integer  NOT NULL ,
	CONSTRAINT PK_ResourceLimits PRIMARY KEY  CLUSTERED (ResourceLimitID ASC)
)
go


insert into dbo.ResourceLimits(ResourceLimitID,ResourceLimitName,ResourceLimitValue)
values
(1, 'Количество мониторов',5),
(2, 'Общее количество параметров',30),
(3,	'Количество пакетов',5),
(4,	'Количество параметров измерения по монитору',10),
(5,	'Количество параметров монитора',4),
(6, 'Количество измерений по монитору',180)
go