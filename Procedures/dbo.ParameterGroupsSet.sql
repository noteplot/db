-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	Процедура записи группы параметров
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGroupsSet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGroupsSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGroupsSet 
@ParameterGroupID			BIGINT out,
@ParameterGroupShortName	NVARCHAR(24),
@ParameterGroupName			NVARCHAR(48),
@LoginID					BIGINT 
AS
BEGIN
	SET NOCOUNT ON;
	IF @ParameterGroupID <0 
	BEGIN
		INSERT INTO dbo.ParameterGroups
		(			
			ParameterGroupShortName,
			ParameterGroupName,
			LoginID
		)
		VALUES
		(
			@ParameterGroupShortName,
			@ParameterGroupName,
			@LoginID
		)
		SET @ParameterGroupID = SCOPE_IDENTITY();  	
	END
	ELSE
		UPDATE dbo.ParameterGroups
		SET
			ParameterGroupShortName = @ParameterGroupShortName,
			ParameterGroupName = @ParameterGroupName,
			LoginID = @LoginID
		WHERE 	
			 ParameterGroupID = @ParameterGroupID
END	
GO
