-- =============================================
-- Author:		[ab]
-- Create date: 20170813
-- Description:	Создание/редактирование/удаление параметра
-- =============================================

IF OBJECT_ID('[dbo].[ParamsSet]', 'P') is null
 EXEC('create procedure [dbo].[ParamsSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParamsSet 
	@ParamID			BIGINT out,
	@ParamShortName		NVARCHAR(24),
	@ParamName			NVARCHAR(48),
	@ParamUnitID		BIGINT,
	@ParamValueTypeID	TINYINT,
	@ParamTypeID		TINYINT,
	@ParameterGroupID	BIGINT,
	@ParamValueMAX		DECIMAL(28,6) = NULL,
	@ParamValueMIN		DECIMAL(28,6) = NULL,
	@LoginID			BIGINT,
	@Active				BIT,			
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
						
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Params WHERE ParamShortName = @ParamShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть параметр с таким названием!',16,2);
				
				INSERT INTO dbo.Parameters(ParameterKindID,ParameterGroupID)
				VALUES(0,@ParameterGroupID)
				SET @ParamID = SCOPE_IDENTITY();
								
				INSERT INTO dbo.Params
				(			
					[ParamID],
					[ParamShortName],
					[ParamName],
					[ParamUnitID],
					[ParamValueTypeID],
					[ParamTypeID],
					[ParamValueMAX],
					[ParamValueMIN],				
					[LoginID]
				)
				VALUES
				(
					@ParamID,
					@ParamShortName,
					@ParamName,
					@ParamUnitID,
					@ParamValueTypeID,
					@ParamTypeID,
					@ParamValueMAX,
					@ParamValueMIN,
					@LoginID
				)
			END
			ELSE
			IF @Mode = 1
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Params WHERE ParamShortName = @ParamShortName AND LoginID = @LoginID)
					RAISERROR('Уже есть параметр с таким названием!',16,3);
			
				UPDATE dbo.Parameters
				SET 					
					ParameterGroupID	= @ParameterGroupID,
					[Active]			= @Active 
				WHERE
					ParameterID			= @ParamID 
				
				
				UPDATE dbo.Params						
				SET
					ParamShortName		= @ParamShortName,
					ParamName			= @ParamName,
					ParamUnitID			= @ParamUnitID,
					ParamValueTypeID	= @ParamValueTypeID,
					ParamTypeID			= @ParamTypeID,
					ParamValueMAX		= @ParamValueMAX,
					ParamValueMIN		= @ParamValueMIN,				
					LoginID				= @LoginID 	
				WHERE ParamID = @ParamID
						
			END
			ELSE					 
			IF @Mode = 2		 
				DELETE FROM dbo.Params	-- AFTER trigger
				WHERE 	
					 ParamID = @ParamID
					 AND LoginID = @LoginID					
			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0 
			ROLLBACK;
		SET @ErrorMessage = ERROR_MESSAGE();				
		RAISERROR(@ErrorMessage,16,4);
		/* 
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
