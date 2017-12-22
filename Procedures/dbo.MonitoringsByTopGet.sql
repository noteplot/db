-- ============================================================
-- Author:		[ab]
-- Create date: 20171202
-- Description:	��������� ������ ���������
-- ============================================================

IF OBJECT_ID('[dbo].[MonitoringsByTopGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringsByTopGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringsByTopGet 
@MonitorID	BIGINT,
@Top		INT = 0 -- ����� ��-��������� �� ������� ��������
AS
BEGIN
	SET NOCOUNT ON;
	SELECT TOP (@Top)
		mg.MonitoringID				AS MonitoringID,
		mg.MonitorID				AS MonitorID,
		mg.MonitoringDate			AS MonitoringDate,
		mg.MonitoringComment		AS MonitoringComment,
		mg.CreationDateUTC			AS CreationDateUTC,
		mg.ModifiedDateUTC			AS ModifiedDateUTC		 
	FROM dbo.Monitorings AS mg
	WHERE
		mg.MonitorID = @MonitorID
	ORDER BY mg.MonitoringDate DESC		 		 		 
END	
GO
