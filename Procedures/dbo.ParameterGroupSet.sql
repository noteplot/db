set quoted_identifier, ansi_nulls on
GO

-- ============================================================
-- Author:		[ab]
-- Create date: 20170723
-- Description:	��������� ������ ������ ����������
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
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT	   		
    			
	BEGIN TRY
		
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('������������ �������� ��������� @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.ParameterGroups WHERE ParameterGroupShortName = @ParameterGroupShortName AND LoginID = @LoginID)
					RAISERROR('��� ���� ������ � ����� ���������!',16,2);
					
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
					RAISERROR('��� ���� ������ � ����� ���������!',16,2);
					
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
					RAISERROR('������ ������ ������������ � ����������!',16,2);
				END
					 
				DELETE FROM dbo.ParameterGroups
				WHERE 	
					 ParameterGroupID = @ParameterGroupID
					 AND LoginID = @LoginID
			END
		COMMIT			 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT != 0 
			ROLLBACK;
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();				
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);		/* 
			SELECT
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage
		*/
	END CATCH
			 
END	
GO
