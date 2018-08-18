set quoted_identifier, ansi_nulls on
GO

-- =============================================
-- Author:		[ab]
-- Create date: 17.08.2018
-- Description:	Логирование ошибок БД
-- =============================================

IF OBJECT_ID('[dbo].[ErrorLogSet]', 'P') is null
 EXEC('create procedure [dbo].[ErrorLogSet] as begin return -1 end')
GO

ALTER PROCEDURE [dbo].[ErrorLogSet]
@LoginID		INT = NULL,
@ProcName		NVARCHAR(128) = NULL, -- процедура ошибки
@Reraise		BIT = 1,	-- возвращаем ошибку
@rollback		BIT = 1		-- откатывать транзакции
AS
BEGIN
	SET NOCOUNT ON;
	if @rollback = 1 and @@TRANCOUNT > 0 ROLLBACK;
	DECLARE
		@ErrorLogDt	datetime2(3) = GETDATE(),
		@ErrorNumber	INT = ERROR_NUMBER(),
		@ErrorSeverity	INT = ERROR_SEVERITY(),
		@ErrorState		INT = ERROR_STATE(),
		@ErrorLine		INT = ERROR_LINE(), 
		@ErrorProcedure	nvarchar(128) = ERROR_PROCEDURE(),
		@ErrorMessage	nvarchar(4000) = ERROR_MESSAGE();
		
	--IF  @ErrorNumber < 50000
	--BEGIN 			  
	IF @ProcName IS NULL SET @ProcName = ERROR_PROCEDURE();
	IF @LoginID IS NULL SET @LoginID = '-1';
		
	BEGIN TRY						  
		INSERT INTO dbo.ErrorLogs(
			ErrorLogDt,
			LoginID,
			ProcedureName,			
			ErrorNumber,
			ErrorSeverity,
			ErrorState,
			ErrorLine, 
			ErrorProcedure,
			ErrorMessage
		)	 
		VALUES(
				@ErrorLogDt, 
				@LoginID,
				@ProcName, 
				@ErrorNumber, 
				@ErrorSeverity, 
				@ErrorState,
				@ErrorLine, 
				@ErrorProcedure, 
				@ErrorMessage
		)		
		SET @ErrorState = 250 -- state = 254 == reraise
	END TRY
	BEGIN CATCH
		SET @ErrorMessage = 'Проблема при логировании ошибки: '+ @ErrorMessage + ' ('+ERROR_MESSAGE()+')';
		SELECT @ErrorState = 255, @ErrorSeverity = 16 
		RAISERROR(@ErrorMessage,16,@ErrorState);
	END CATCH
	--END;
	IF (@Reraise = 1)
		RAISERROR(@ErrorMessage, @ErrorSeverity,@ErrorState); 
	
END
GO