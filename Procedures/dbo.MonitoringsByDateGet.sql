set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171202
-- Description:	Процедура списка измерений
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringsByDateGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringsByDateGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringsByDateGet 
@MonitorID	BIGINT,
@DateFrom DATETIME2(0),
@DateTo DATETIME2(0)
AS
BEGIN
	DECLARE 
		@dt1 DATETIME2(0),@dt2 DATETIME2(0),@cd DATETIME2(0) = GETDATE()
		 	
	IF @DateTo IS NULL 
		SET @dt2 = cast(DATEADD(dd,1,@cd) AS DATE)
	ELSE
		SET @dt2 = cast(DATEADD(dd,1,@DateTo) AS DATE)

	IF @DateFrom IS NULL
		SET @dt1 = cast(DATEADD(dd,-1,@dt2) AS DATE)
	ELSE
		SET @dt1 = cast(@DateFrom AS DATE);					
			 
	SET NOCOUNT ON;
	SELECT
		mg.MonitoringID				AS MonitoringID,
		mg.MonitorID				AS MonitorID,		
		mg.MonitoringDate			AS MonitoringDate,
		mg.MonitoringComment		AS MonitoringComment, 
		mg.CreationDateUTC				AS CreationDateUTC,
		mg.ModifiedDateUTC				AS ModifiedDateUTC		 
	FROM dbo.Monitorings AS mg
	WHERE
		mg.MonitorID = @MonitorID		
		AND mg.MonitoringDate >= @dt1
		AND mg.MonitoringDate < @dt2
	ORDER BY mg.MonitoringDate DESC		 		 		 
END	
GO
