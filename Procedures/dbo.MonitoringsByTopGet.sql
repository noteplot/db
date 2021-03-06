set quoted_identifier, ansi_nulls on
GO

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
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitoringsByTopGet';--		 	
	
	BEGIN TRY
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
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 			
		DECLARE @LoginID BIGINT
		SELECT @LoginID = m.LoginID FROM dbo.Monitors AS m (nolock)
		WHERE m.MonitorID = @MonitorID
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 		 			 		 		 
END	
GO
