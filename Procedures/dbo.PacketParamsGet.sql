set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20171105
-- Description:	Процедура получения списка параметров
-- для пакета
-- =============================================

IF OBJECT_ID('[dbo].[PacketParamsGet]', 'P') is null
 EXEC('create procedure [dbo].[PacketParamsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.PacketParamsGet 
@PacketID bigint
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.PacketParamsGet';--
	
	BEGIN TRY
		SELECT 
			pp.PacketID,
			pp.ParamID AS ParameterID,
			p.ParamShortName AS ParameterShortName,
			pp.Active AS PacketParameterActive	
		FROM dbo.PacketParams AS pp
		JOIN dbo.Params AS p ON p.ParamID = pp.ParamID
		WHERE pp.PacketID = @PacketID
		ORDER BY pp.PacketParamPosition
	END TRY	
	BEGIN CATCH
		DECLARE @LoginID BIGINT
		SELECT @LoginID = p.LoginID FROM dbo.Packets AS p (nolock) 
		WHERE p.PacketID = @PacketID
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 								
END
GO
