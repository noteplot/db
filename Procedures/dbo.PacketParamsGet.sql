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
	SELECT 
		pp.PacketID,
		pp.ParamID AS ParameterID,
		p.ParamShortName AS ParameterShortName,
		pp.Active AS PacketParameterActive	
	FROM dbo.PacketParams AS pp
	JOIN dbo.Params AS p ON p.ParamID = pp.ParamID
	WHERE pp.PacketID = @PacketID
	ORDER BY pp.PacketParamPosition	
END
GO
