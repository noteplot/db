set quoted_identifier, ansi_nulls on
go

-- ============================================================
-- Author:		[ab]
-- Create date: 20171118
-- Description:	Процедура списка параметров монитора
-- ============================================================

IF OBJECT_ID('[dbo].[MonitorParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorParamsGet
@MonitorID	BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitorParamsGet';--

	DECLARE 
		@PackName VARCHAR(255) = 'Пакет';
		
	BEGIN TRY	 
		SELECT 
			m.MonitorID					AS MonitorID,
			mp.ParameterID				AS ParameterID,
		
			IIF(pm.ParamID IS NOT NULL, pm.ParamShortName, pc.PacketShortName) AS ParameterShortName,
			IIF(pm.ParamID IS NOT NULL, pm.ParamName, pc.PacketName) AS ParameterName,
			pm.ParamTypeID				AS ParameterTypeID,
			IIF(pm.ParamID IS NOT NULL, pt.ParamTypeName, @PackName) AS ParameterTypeName,

			mp.MonitorParamPosition		AS MonitorParamPosition,		
			pv.MonitorParamValue		AS MonitorParameterValue,			
			mp.[Active]					AS MonitorParameterActive,
			mp.MonitorParamPosition		AS MonitorParamPosition	 
		FROM dbo.Monitors AS m
		JOIN dbo.MonitorParams AS mp ON mp.MonitorID = m.MonitorID
		JOIN dbo.Parameters AS p ON p.ParameterID = mp.ParameterID
		LEFT JOIN dbo.Params AS pm ON pm.ParamID = p.ParameterID
		LEFT JOIN dbo.ParamTypes AS pt ON pt.ParamTypeID = pm.ParamTypeID
		LEFT JOIN dbo.MonitorTotalParamValues AS pv ON pv.MonitorParamID = mp.MonitorParamID
		LEFT JOIN dbo.Packets AS pc ON pc.PacketID = p.ParameterID
		WHERE 
			m.MonitorID = @MonitorID
		ORDER BY mp.MonitorParamPosition
	END TRY
	BEGIN CATCH
		DECLARE @LoginID BIGINT
		SELECT @LoginID = m.LoginID FROM dbo.Monitors AS m (nolock)
		WHERE m.MonitorID = @MonitorID
			
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 	
END
GO	