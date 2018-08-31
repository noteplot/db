set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	Процедура записи группы параметров
-- ============================================================

IF OBJECT_ID('[dbo].[ParameterGroupSet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterGroupSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterGroupSet 
@ParameterGroupID			BIGINT out,
@ParameterGroupShortName	NVARCHAR(24),
@ParameterGroupName			NVARCHAR(48),
@LoginID					BIGINT,
@Mode						TINYINT -- 0 - insert 1 - edit 2 - delete 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.ParameterGroupSet';--
    			
	BEGIN TRY		
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.ParameterGroups WHERE ParameterGroupShortName = @ParameterGroupShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть группа с таким названием!',16,2);
					
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
			IF @Mode = 1
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.ParameterGroups (updlock) WHERE ParameterGroupShortName = @ParameterGroupShortName AND LoginID = @LoginID
				AND ParameterGroupID != @ParameterGroupID)
					RAISERROR('Уже есть группа с таким названием!',16,2);
					
				UPDATE dbo.ParameterGroups
				SET
					ParameterGroupShortName = @ParameterGroupShortName,
					ParameterGroupName = @ParameterGroupName				
				WHERE 	
					 ParameterGroupID = @ParameterGroupID
					 AND LoginID = @LoginID
			END				 
			ELSE					 
			IF @Mode = 2
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Parameters AS p (updlock) WHERE p.ParameterGroupID = @ParameterGroupID) 
				BEGIN
					RAISERROR('Данная группа используется в параметрах!',16,2);
				END
					 
				DELETE FROM dbo.ParameterGroups
				WHERE 	
					 ParameterGroupID = @ParameterGroupID
					 AND LoginID = @LoginID
			END
		COMMIT			 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 	
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH			 
END	
GO
