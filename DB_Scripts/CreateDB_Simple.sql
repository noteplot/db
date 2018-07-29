/*
USE [master]
go

ALTER DATABASE NP1
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE [NP1]
GO
 */

set noexec off
GO

use master
go

DECLARE @DB nvarchar(512) = 'NP1'; 
if exists
(
	select * from sys.databases where name = @DB
)
begin
	raiserror('Database already exists',16,1)
	set noexec on
end
--go


declare
	@version int
	,@dataPath nvarchar(512)
	,@logPath nvarchar(512)	
SELECT @version
set @version = 
	convert(int,
		left(
			convert(nvarchar(128), serverproperty('ProductVersion')),
			charindex('.',convert(nvarchar(128), serverproperty('ProductVersion'))) - 1
		)
	);

SELECT @version

if @version >= 11 -- SQL Server 2012+
begin
	select 
		@dataPath = convert(nvarchar(512),serverproperty('InstanceDefaultDataPath'))
		,@logPath = convert(nvarchar(512),serverproperty('InstanceDefaultLogPath'))
end
else begin
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', @dataPath output
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog', @logPath output
END

-- Creating database in the same folder with master
if @dataPath is null
	select @dataPath = substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) + '\'
	from master.sys.database_files 
	where file_id = 1

if @logPath is null
	select @logPath = substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) + '\'
	from master.sys.database_files 
	where file_id = 2
	
if @dataPath is null or @logPath is null
begin
	raiserror('Cannot obtain path for data and/or log file',16,1)
	set noexec on
end

select @dataPath,@logPath


if right(@dataPath, 1) <> '\'
	select @dataPath = @dataPath + '\'
if right(@logPath, 1) <> '\'
	select @logPath = @logPath + '\'

select @dataPath,@logPath

--RETURN
	
declare
	@SQL nvarchar(max)

select @SQL =
REPLACE( 
	replace
	(
		replace(
N'create database [%DB%]
on PRIMARY (name=N''np'', filename=N''%DATA%noteplot.mdf'', size=10MB, filegrowth = 10MB),
filegroup [NP_DATA] (name=N''np_data'', filename=N''%DATA%noteplot_data.ndf'', size=100MB, filegrowth = 100MB)
log on (name=N''NP_log'', filename=N''%LOG%noteplot_log.ldf'', size=256MB, filegrowth = 256MB);

alter database [%DB%] set recovery simple;
alter database [%DB%] modify filegroup [NP_DATA] default;

alter database [%DB%] SET ANSI_NULL_DEFAULT OFF; 
alter database [%DB%] SET ANSI_NULLS ON;
alter database [%DB%] SET ANSI_PADDING ON;
alter database [%DB%] SET ANSI_WARNINGS ON;
alter database [%DB%] SET ARITHABORT ON;
alter database [%DB%] SET QUOTED_IDENTIFIER ON; 
alter database [%DB%] SET CONCAT_NULL_YIELDS_NULL ON;
alter database [%DB%] SET NUMERIC_ROUNDABORT OFF; 
'
			,'%DATA%',@dataPath
		),'%LOG%',@logPath
	),'%DB%',@DB
)	
SELECT @sql
/*
raiserror('Creating database NP1',0,1) with nowait
raiserror('Data Path: %s',0,1,@dataPath) with nowait
raiserror('Log Path: %s',0,1,@logPath) with nowait
raiserror('Statement:',0,1) with nowait
raiserror(@sql,0,1) with nowait
*/
exec sp_executesql @sql
go

