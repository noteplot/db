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
(2, 'Количество параметров в мониторе',5),
(3, 'Количество измерений в мониторе',180)
go