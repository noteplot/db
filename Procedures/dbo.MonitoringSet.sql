-- =============================================
-- Author:		[ab]
-- Create date: 20171224
-- Description:	Создание/редактирование/удаление измерения
-- JSON - последовательность полей в записи: 
-- MonitoringParamID,MonitorParamID,ParameterID,ParameterValue
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

IF OBJECT_ID('[dbo].[MonitoringSet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringSet 
	@MonitoringID		BIGINT out,
	@MonitorID			BIGINT,
	@MonitoringDate		DATETIME2(0),
	@MonitoringComment	NVARCHAR(255),
	@JSON				VARCHAR(MAX),			
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT,
		@lMonitoringParamID int	= LEN('"MonitoringParamID":"'),
		@lMonitorParamID int	= LEN('"MonitorParamID":"'),					   		
		@lParameterID int		= LEN('"ParameterID":"'),
		@lParameterValue int	= LEN('"ParameterValue":"'),
		@sParameterValue NVARCHAR(255) = '"ParameterValue":"',
		@rMonitoringParamID BIGINT,
		@rMonitorParamID BIGINT, 
		@rParameterID BIGINT, 
		@rParameterValue DECIMAL(28,6),
		@comma char(1) = ',',@point char(1) = '.';
								
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode = 0
			BEGIN
				IF @MonitorID IS NULL	 
					RAISERROR('Не указан щаблон измерения',16,2);
			END
		
			IF @Mode = 1
			BEGIN
				IF @MonitoringID IS NULL
					RAISERROR('Не указано измерение параметров.',16,3);
			END
			
			IF @Mode IN (0,1)
			BEGIN
				IF @MonitoringDate IS NULL	 
					RAISERROR('Не установлено время измерения',16,4);
					
				IF @JSON IS NULL
					RAISERROR('Нет списка параметров измерения',16,5);
					
				IF EXISTS(SELECT 1 FROM dbo.Monitorings WHERE MonitorID = @MonitorID AND MonitoringDate =@MonitoringDate  
				AND MonitoringID != IsNull(@MonitoringID,0)) 
					RAISERROR('Уже есть измерение с такой датой и временем!',16,6);
			END
			
			IF @Mode IN (0,1) 
			BEGIN
				declare
					@pars table (
						MonitoringParamID BIGINT NULL,
						MonitorParamID BIGINT NOT NULL,
						ParamID BIGINT NOT NULL,
						ParamValue DECIMAL(28,6) NOT NULL
					)
				declare		
					@ind1 bigint=0, @ind2 bigint=0, @id int = 1 

				-- значения параметров
				set @JSON = REPLACE(REPLACE(REPLACE(REPLACE(@JSON, char(10), ''),CHAR(13),''),CHAR(9),''),CHAR(32),'');
				DECLARE @rowId INT = 1				
				while(1=1)
				begin
					set @ind1 = CHARINDEX('"MonitoringParamID":"',@JSON,@ind1)
					if @ind1 = 0
						break;
					set @ind1 += @lMonitoringParamID
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0 
					BEGIN		
						IF @Mode = 1
						BEGIN				
							RAISERROR('Не определено значение идентификатора записи в измерении!',16,6);	
							break;
						END
						else
							SET @rMonitoringParamID = NULL
					END
					ELSE
					BEGIN		
						IF SUBSTRING(@JSON,@ind1,@ind2-@ind1) = ''
							set @rMonitoringParamID = NULL
						ELSE
							set @rMonitoringParamID = SUBSTRING(@JSON,@ind1,@ind2-@ind1);
					END	

					set @ind1 = CHARINDEX('"MonitorParamID":"',@JSON,@ind1)--+@lMonitorParamID
					if @ind1 = 0
					BEGIN
						RAISERROR('Не определен идентификатор параметра в шаблоне измерения!',16,6);
						break;						
					END
						
					set @ind1 += @lMonitorParamID
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Не определено значение идентификатора параметра в шаблоне измерения!',16,6);	
						break;
					END		
					ELSE
						set @rMonitorParamID = SUBSTRING(@JSON,@ind1,@ind2-@ind1)

					set @ind1 = CHARINDEX('"ParameterID":"',@JSON,@ind1)--+@lParameterID
					if @ind1 = 0
					BEGIN
						RAISERROR('Не определен идентификатор параметра!',16,6);
						break;
					END;	
					set @ind1 += @lParameterID
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Не определено значение идентификатора параметра!',16,6);	
						break;
					END;	
					set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
					
					SET @sParameterValue = '"ParameterValue'+CAST(@id AS NVARCHAR(255))+'":"';
					SET @lParameterValue = LEN(@sParameterValue);
					 
					set @ind1 = CHARINDEX(@sParameterValue,@JSON,@ind2)--+@lParameterValue
					if @ind1 = 0
					BEGIN
						RAISERROR('Не указано идентификатор значения параметра!',16,7);	
						break;
					END;
					set @ind1 += @lParameterValue						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Не указано значение параметра!',16,8);	
						break;
					END;						
					set @rParameterValue  = REPLACE(nullif(SUBSTRING(@JSON,@ind1,@ind2-@ind1),''),@comma,@point);
					
					insert into @pars(MonitoringParamID,MonitorParamID,ParamID,ParamValue)
						select @rMonitoringParamID,@rMonitorParamID,@rParameterID,@rParameterValue
						
					set @id += 1
				end
			END		
					
			IF @Mode = 0
			BEGIN
				if exists(SELECT top 1 1
				FROM @pars 
				GROUP BY ParamID
				HAVING(COUNT(1) > 1)
				)
					RAISERROR('Параметры в измерении не должны дублироваться!',16,12);				
			END
			
			IF @Mode = 0 
			BEGIN
				INSERT INTO dbo.Monitorings(MonitorID,MonitoringDate,MonitoringComment)
				VALUES(@MonitorID,@MonitoringDate,@MonitoringComment)
				SET @MonitoringID = SCOPE_IDENTITY();
				
				INSERT INTO dbo.MonitoringParams
				(
					MonitoringID,
					MonitorParamID,
					ParamID,
					ParamValue
				)
				SELECT
					@MonitoringID, 
					MonitorParamID, 
					ParamID,
					ParamValue
				FROM @pars 
			END
			ELSE
			IF @Mode = 1
			BEGIN
				UPDATE dbo.Monitorings
				SET 					
					MonitoringDate	  = @MonitoringDate,
					MonitoringComment = @MonitoringComment				
				WHERE
					MonitoringID = @MonitoringID
					AND  (MonitoringDate != @MonitoringDate OR MonitoringComment != @MonitoringComment)
					
				UPDATE mp
				SET
					mp.ParamValue = p.ParamValue					 				
				from dbo.MonitoringParams AS mp
				JOIN @pars as p ON p.MonitoringParamID = mp.MonitoringParamID
				AND p.ParamValue != mp.ParamValue 
				WHERE mp.MonitoringID = @MonitoringID	
			END
			ELSE					 
			IF @Mode = 2
			BEGIN
				DELETE FROM dbo.MonitoringParams	
				WHERE 	
				MonitoringID		= @MonitoringID

				DELETE FROM dbo.Monitorings			
				WHERE 	
				MonitoringID		= @MonitoringID				
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
