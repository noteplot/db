set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 20170813
-- Description:	Удаление параметра
-- =============================================

IF OBJECT_ID('[dbo].[ParameterDelete]', 'P') is null
 EXEC('create procedure [dbo].[ParameterDelete] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterDelete 
	@ParameterID		BIGINT,
	@LoginID			BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);

	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.ParameterDelete';--
						
	DECLARE
		@ResourceLimitID INT = 2; -- кол-во параметров по логину
						
	BEGIN TRY
		BEGIN TRAN
			IF EXISTS(SELECT 1 FROM dbo.PacketParams WHERE ParamID = @ParameterID)
			BEGIN
				set @ErrorMessage = 'Данный параметр входит в пакет. Перед удалением необходимо исключить его из пакета.'
				RAISERROR(@ErrorMessage,16,1);
			END 

			IF EXISTS(SELECT 1 FROM dbo.ParamRelations WHERE SecondaryParamID = @ParameterID)
			BEGIN
				set @ErrorMessage = 'Данный параметр используется для вычисления других параметров. Перед удалением необходимо исключить его из расчетов.'
				RAISERROR(@ErrorMessage,16,1);
			END 
			
			DELETE FROM dbo.ParamRelations	-- AFTER trigger
			WHERE 	
					PrimaryParamID = @ParameterID
			
			DELETE FROM dbo.Params	-- AFTER trigger
			WHERE 	
					ParamID = @ParameterID
					AND LoginID = @LoginID

			DELETE FROM dbo.Parameters
			WHERE 	
					ParameterID = @ParameterID
							
			-- уменьшение счетчика
			UPDATE dbo.ResourceCounts
				SET [Value] -= 1
			WHERE LoginID = @LoginID AND ResourceLimitID = @ResourceLimitID
										
			COMMIT			
	END TRY
	BEGIN CATCH
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  
END
GO
