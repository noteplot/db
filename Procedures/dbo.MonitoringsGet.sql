-- ============================================================
-- Author:		[ab]
-- Create date: 20171216
-- Description:	Список измерений по монитору
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringsGet 
@MonitorID	BIGINT,
@Tops		INT = 10,
@DateFrom	DATETIME2(0) = NULL,
@DateTo		DATETIME2(0) = NULL,	
@Mode		TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON;
	if @Mode = 0
		exec dbo.MonitoringsByTopGet @MonitorID, @Tops
	else
		exec dbo.MonitoringsByDateGet  @MonitorID,@DateFrom,@DateTo
END	
GO
