set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20180204
-- Description:	Создание/редактирование/удаление группы ед.изм
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

IF OBJECT_ID('[dbo].[UnitGroupSet]', 'P') is null
 EXEC('create procedure [dbo].[UnitGroupSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.UnitGroupSet 
	@UnitGroupID			BIGINT OUT,
	@UnitGroupShortName		NVARCHAR(24),
	@UnitGroupName			NVARCHAR(48),
	@LoginID				BIGINT,
	@Mode					TINYINT	
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
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			
			IF @Mode = 0 -- ins 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.UnitGroups WHERE UnitGroupShortName = @UnitGroupShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть параметр с таким кратким названием!',16,2);				
												
				INSERT INTO dbo.UnitGroups
				(			
					[UnitGroupShortName],
					[UnitGroupName],
					[LoginID]
				)
				VALUES
				(
					@UnitGroupShortName,
					@UnitGroupName,
					@LoginID
				)
				SET @UnitGroupID = SCOPE_IDENTITY();  
			END
			ELSE
			IF @Mode = 1
			BEGIN
				IF @UnitGroupID IS NULL
					RAISERROR('Группа не установлена!',16,3);
				IF EXISTS(SELECT 1 FROM dbo.UnitGroups WHERE UnitGroupID != @UnitGroupID and UnitGroupShortName = @UnitGroupShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть параметр с таким кратким названием!',16,4);				

				UPDATE dbo.UnitGroups
				SET 					
					UnitGroupShortName = @UnitGroupShortName,
					UnitGroupName = @UnitGroupName
				WHERE
					UnitGroupID	= @UnitGroupID
					AND LoginID = @LoginID 
			END
			ELSE					 
			IF @Mode = 2
			BEGIN
				IF EXISTS(
					SELECT 1 FROM dbo.Units AS u
					WHERE u.UnitGroupID = @UnitGroupID AND u.LoginID = @LoginID 
				)
				BEGIN
					RAISERROR('Группа используется в ед.измерения!',16,5);
				END	
				
				DELETE FROM dbo.UnitGroups	-- AFTER trigger
				WHERE 	
					 UnitGroupID = @UnitGroupID
					 AND LoginID = @LoginID
			END
			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT != 0 
			ROLLBACK;
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();				
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH	  
END
GO
