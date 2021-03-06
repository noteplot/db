set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20171028
-- Description:	��������� ��������� ������ ������� ��� ������
-- ============================================================

IF OBJECT_ID('[dbo].[PacketGet]', 'P') is null
 EXEC('create procedure [dbo].[PacketGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.PacketGet
@PacketID	BIGINT = null,
@LoginID	BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.PacketGet';--
	BEGIN TRY	
		SELECT 
			p.PacketID					AS PacketID,
			ps.ParameterGroupID			AS ParameterGroupID,
			pg.ParameterGroupShortName	AS ParameterGroupShortName,		
			p.PacketShortName			AS PacketShortName,
			p.PacketName				AS PacketName,		
			p.LoginID					AS LoginID,
			ps.[Active]					AS [Active] 
		FROM dbo.Packets AS p
		JOIN dbo.Parameters AS ps ON ps.ParameterID = p.PacketID
		JOIN dbo.ParameterGroups AS pg ON pg.ParameterGroupID = ps.ParameterGroupID
		WHERE 
			ps.ParameterID = IsNull(@PacketID,ps.ParameterID) and
			p.LoginID IN (0,@LoginID)
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH				 			 		 								 
END	
GO
