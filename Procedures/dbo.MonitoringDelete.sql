-- =============================================
-- Author:		[ab]
-- Create date: 20171226
-- Description:	Удаление измерения по монитору
-- =============================================

IF OBJECT_ID('[dbo].[MonitoringDelete]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringDelete 
	@MonitoringID		BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	exec dbo.MonitoringSet @MonitoringID = @MonitoringID,@Mode = 2
END
GO
