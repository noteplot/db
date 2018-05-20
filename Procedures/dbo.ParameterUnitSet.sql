set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20180216
-- Description:	Создание/редактирование/удаление ед.изм
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

IF OBJECT_ID('[dbo].[ParameterUnitSet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterUnitSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterUnitSet 
	@UnitID				BIGINT OUT,
	@UnitShortName		NVARCHAR(24),
	@UnitName			NVARCHAR(48),
	@UnitGroupID		BIGINT, 
	@LoginID			BIGINT,
	@Mode				TINYINT	
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
				IF EXISTS(SELECT 1 FROM dbo.Units WHERE UnitShortName = @UnitShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть ед. измерения с таким кратким названием!',16,2);				
												
				INSERT INTO dbo.Units
				(			
					[UnitShortName],
					[UnitName],
					[UnitGroupID],
					[LoginID]
				)
				VALUES
				(
					@UnitShortName,
					@UnitName,
					@UnitGroupID,
					@LoginID
				)
				SET @UnitID = SCOPE_IDENTITY();  
			END
			ELSE
			IF @Mode = 1
			BEGIN
				IF @UnitID IS NULL
					RAISERROR('Ед. измерения не установлена!',16,3);
				IF EXISTS(SELECT 1 FROM dbo.Units WHERE UnitID != @UnitID and UnitShortName = @UnitShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть ед. измерения с таким кратким названием!',16,4);				

				UPDATE dbo.Units
				SET 					
					UnitShortName = @UnitShortName,
					UnitName = @UnitName,
					UnitGroupID = @UnitGroupID
				WHERE
					UnitID	= @UnitID
					AND LoginID = @LoginID 
			END
			ELSE					 
			IF @Mode = 2
			BEGIN
				IF EXISTS(
					SELECT 1 FROM dbo.Params AS p
					WHERE p.ParamUnitID = @UnitID AND p.LoginID = @LoginID 
				)
				BEGIN
					RAISERROR('Ед.измерения используется в параметрах!',16,5);
				END	
				
				DELETE FROM dbo.Units	-- AFTER trigger
				WHERE 	
					 UnitID = @UnitID
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
