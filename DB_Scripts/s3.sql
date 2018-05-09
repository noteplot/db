--select *
--from sys.dm_fts_parser(' "строка, которую нужно как-нибудь распарсить" ', 1049, 0, 0)

DECLARE 
	@MonitorParams VARCHAR(MAX) = '1121212121,2,31212212121212,4,5,6,7';
declare 
	@delimeter nvarchar(1) = ','

DECLARE @mp TABLE(
		MonitorParamID bigint
)

declare @pos int = charindex(@delimeter,@MonitorParams)
declare @id nvarchar(20)
    
while (@pos != 0)
begin
    -- получаем айдишник
    set @id = SUBSTRING(@MonitorParams, 1, @pos-1)
    -- записываем в таблицу
    insert into @mp (MonitorParamID) values(cast(@id as bigint))
    set @MonitorParams = SUBSTRING(@MonitorParams, @pos+1, LEN(@MonitorParams))
    -- определяем позицию след. разделителя
    set @pos = CHARINDEX(@delimeter,@MonitorParams)
END

SELECT * FROM @mp