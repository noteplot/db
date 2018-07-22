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
(1, ' оличество мониторов',5),
(2, 'ќбщее количество параметров',30),
(3,	' оличество пакетов',5),
(4, ' оличество измерений по монитору',180),
(5,	' оличество параметров(простых и расчетных) по монитору дл€ измерени€',10),
(6,	' оличество параметров(итоговых) монитора',4)

go