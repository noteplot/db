set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171218
-- Description:	Фильтр для монитора по-умолчанию
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringFilterGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringFilterGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringFilterGet
@MonitorID	BIGINT,
@LoginID	BIGINT = null 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@cd DATE = GETDATE();
		
			
	SELECT 
		m.MonitorID					AS MonitorID,
		m.MonitorShortName			AS MonitorShortName,
		m.MonitorName				AS MonitorName,
		IsNull(mf.Tops,10)			AS Tops,
		cast(DATEADD(dd,-IsNull(mf.Days,30),@cd) AS DATE)	AS DateFrom,								
		@cd							AS DateTo
	FROM dbo.Monitors AS m
	LEFT JOIN dbo.MonitoringFilterSettings AS mf ON 1 = 1	 
	WHERE
		m.MonitorID = @MonitorID
		 
END	
GO
