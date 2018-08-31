set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171111
-- Description:	Процедура получения списка мониторов или монитора
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorGet
@MonitorID	BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitorGet';--
	
	BEGIN TRY
		SELECT 
			m.MonitorID					AS MonitorID,
			m.MonitorShortName			AS MonitorShortName,
			m.MonitorName				AS MonitorName,		
			m.LoginID					AS LoginID,
			m.[Active]					AS [Active] 
		FROM dbo.Monitors AS m
		WHERE
			m.MonitorID = ISNULL(@MonitorID,m.MonitorID) 
			and m.LoginID IN (0,@LoginID)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback= 1;
		RETURN 1;	
	END CATCH
END	
GO
