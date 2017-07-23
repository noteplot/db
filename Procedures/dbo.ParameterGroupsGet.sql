-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	��������� ��������� ������ ����� ����������
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGroupsGet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGroupsGet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGroupsGet 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		ParameterGroupID,
		ParameterGroupShortName,				
		ParameterGroupName,
		LoginID
	FROM dbo.ParameterGroups
END	
GO
