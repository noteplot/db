-- =============================================
-- Author:		[ab]
-- Create date: 20171224
-- Description:	Создание/редактирование/удаление измерения
-- JSON - последовательность полей в записи: 
-- MonitoringParamID,MonitorParamID,ParameterID,ParameterTypeID,ParameterValue
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

IF OBJECT_ID('[dbo].[MonitoringSet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringSet 
	@MonitoringID		BIGINT out,
	@MonitorID			BIGINT = NULL,
	@MonitoringDate		DATETIME2(0) = NULL,
	@MonitoringComment	NVARCHAR(255) = NULL,
	@JSON				VARCHAR(MAX) = NULL,			
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
		@lParameterTypeID INT	= LEN('"ParameterTypeID":"'),
		@sParameterValue NVARCHAR(255) = '"ParameterValue":"',						
		@rMonitoringParamID BIGINT,
		@rMonitorParamID BIGINT, 
		@rParameterID BIGINT, 
		@rParameterValue DECIMAL(28,6),
		@rParameterTypeID TINYINT,
		@comma char(1) = ',',@point char(1) = '.',
		@rs INT = 0,
		@rc INT = 0,
		@rt INT = 0,
		@rl INT = 0,
		@ParamID BIGINT,
		@ParamNewID BIGINT,
		@MonitorParamID BIGINT,
		@RelationParamID	BIGINT,
		@MathOperationID	TINYINT,
		@ParamValue  DECIMAL(28,6),
		@ParamCalcValue  DECIMAL(28,6) = 0,
		@RelationParamValue  DECIMAL(28,6),
		@OldRelationParamValue  DECIMAL(28,6),						
		@Scale TINYINT = 0;
								
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
			IF @Mode IN (1,2)
			BEGIN
				IF @MonitorID IS NULL
				BEGIN	 
					SELECT @MonitorID = MonitorID FROM dbo.MonitoringParams AS mp
					JOIN dbo.MonitorParams AS mp2 ON mp2.MonitorParamID = mp.MonitorParamID
					WHERE mp.MonitoringID = @MonitoringID
				END	
			END
		
			IF @Mode = 0
			BEGIN
				IF @MonitorID IS NULL	 
					RAISERROR('Не указан шаблон измерения',16,2);
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

			declare
				@pars table (
					MonitoringParamID BIGINT NULL,
					MonitorParamID BIGINT NOT NULL,
					ParamID BIGINT NOT NULL,
					ParamValue DECIMAL(28,6) NULL,
					ParamTypeID TINYINT NOT NULL,
					OldParamValue DECIMAL(28,6) NULL
				)
			
			IF @Mode IN (0,1) 
			BEGIN
				declare
					@parc table (
						ID INT IDENTITY(1,1) PRIMARY KEY,
						MonitoringParamID BIGINT NULL,
						MonitorParamID BIGINT NOT NULL,
						ParamID BIGINT NOT NULL,
						ParamValue DECIMAL(28,6) NULL,
						Scale TINYINT NOT NULL
					)

				DECLARE @prel table(
						ID INT IDENTITY(1,1) PRIMARY KEY,						
						PrimaryParamID BIGINT NOT NULL,
						SecondaryParamID BIGINT NOT NULL,
						CalcType INT NOT NULL,
						MathOperationID TINYINT NOT NULL,
						Scale TINYINT NOT NULL
				)	
				-- параметры монитора
				DECLARE @mrel table(
						ID INT IDENTITY(1,1) PRIMARY KEY,
						MonitorParamID BIGINT NOT NULL,						
						ParamID BIGINT NOT NULL,
						RelationParamID BIGINT NOT NULL,
						RelationParamValue DECIMAL(28,6) NOT NULL,
						OldRelationParamValue DECIMAL(28,6) NULL,
						MathOperationID TINYINT NOT NULL,
						Scale TINYINT NOT NULL
				)
					
				declare		
					@ind1 bigint=0, @ind2 bigint=0, @id int = 1 

				-- значения параметров
				set @JSON = REPLACE(REPLACE(REPLACE(REPLACE(@JSON, char(10), ''),CHAR(13),''),CHAR(9),''),CHAR(32),'');
				--DECLARE @rowId INT = 1				
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
					
					set @ind1 = CHARINDEX('"ParameterTypeID":"',@JSON,@ind1)--+@lParameterID
					if @ind1 = 0
					BEGIN
						RAISERROR('Не определен идентификатор типа параметра!',16,6);
						break;
					END;	
					set @ind1 += @lParameterTypeID
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Не определен тип параметра!',16,6);	
						break;
					END;	
					set @rParameterTypeID = SUBSTRING(@JSON,@ind1,@ind2-@ind1)

					SET @sParameterValue = '"ParameterValue'+CAST(@id AS NVARCHAR(255))+'":"';
					SET @lParameterValue = LEN(@sParameterValue);
					 
					set @ind1 = CHARINDEX(@sParameterValue,@JSON,@ind2)--+@lParameterValue
					if @ind1 = 0
					BEGIN
						RAISERROR('Не указан идентификатор значения параметра!',16,7);	
						break;
					END;
					set @ind1 += @lParameterValue						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						set @rParameterValue = NULL -- для расчетных значений
						--RAISERROR('Не указано значение параметра!',16,8);	
						--break;
					END						
					set @rParameterValue  = REPLACE(nullif(SUBSTRING(@JSON,@ind1,@ind2-@ind1),''),@comma,@point);
					
					insert into @pars(MonitoringParamID,MonitorParamID,ParamID,ParamValue,ParamTypeID,OldParamValue)
						select @rMonitoringParamID,@rMonitorParamID,@rParameterID,@rParameterValue,@rParameterTypeID,
						(SELECT mp.ParamValue FROM dbo.MonitoringParams AS mp where @rMonitoringParamID IS NOT NULL and mp.MonitoringParamID = @rMonitoringParamID) -- считываем текущее значение параметра монитора
					SET @rs += 1;	
					IF @rParameterTypeID = 1
					BEGIN
						insert into @parc(MonitoringParamID,MonitorParamID,ParamID,ParamValue,Scale)
							select @rMonitoringParamID,@rMonitorParamID,@rParameterID,@rParameterValue,pvt.Scale
							FROM dbo.Params AS p
							JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID 
							WHERE ParamID = @rParameterID
						SET @rc += 1;
					END
					set @id += 1
				END				
			END
			ELSE
				BEGIN -- удаление
					INSERT INTO @pars(
						MonitoringParamID,
						MonitorParamID,
						ParamID,
						ParamValue,
						ParamTypeID,
						OldParamValue
						)
					SELECT 
						mp.MonitoringID,
						mp.MonitorParamID,
						mp.ParamID,
						0, -- удаляем из параметра монитора	
						p.ParamTypeID,
						mp.ParamValue 
					FROM dbo.MonitoringParams AS mp
					JOIN dbo.Params AS p ON p.ParamID = mp.ParamID					
					WHERE mp.MonitoringID = @MonitoringID
				END					
			
			IF @Mode IN (0,1) 
			BEGIN
				IF EXISTS(
					SELECT 1 FROM @pars AS p
					JOIN dbo.Params AS p2 ON p2.ParamID = p.ParamID AND p2.ParamTypeID = 0
					WHERE p.ParamValue IS NULL 
				)
				BEGIN
					RAISERROR('Для всех параметров должно быть указано значение измерения!',16,7);	
				END	
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

		BEGIN TRAN										
			-- Расчетные параметры
			IF @Mode IN (0,1)
			BEGIN
				IF @rc > 0
				BEGIN
						INSERT INTO @prel(
							PrimaryParamID,
							SecondaryParamID,
							CalcType,
							MathOperationID,
							Scale							
						)
						SELECT
							PrimaryParamID,
							SecondaryParamID,
							CalcType,
							MathOperationID,
							Scale													 
						FROM (	
							SELECT 
								pr.PrimaryParamID,
								pr.SecondaryParamID,
								SUM(p2.ParamTypeID) OVER(PARTITION BY pr.[PrimaryParamID]) AS CalcType,
								pr.MathOperationID,
								p.Scale
							FROM dbo.ParamRelations AS pr
							JOIN @parc AS p ON p.ParamID = pr.PrimaryParamID
							JOIN @pars AS p2 ON p2.ParamID = pr.SecondaryParamID																		
						) AS p	
						ORDER BY p.CalcType -- сортируем по наличию в связанных параметрах вычисляемых типов - сначала вычисляем все расчетные параметры, на основании простых
						SET @rl = @@ROWCOUNT
						SELECT @id = 1,@ParamID = -1,@ParamCalcValue = 0; 
					WHILE(1=1)
					BEGIN
						IF @id <= @rl
						BEGIN
							SELECT 
								@ParamNewID = p.PrimaryParamID,
								@RelationParamID = p.SecondaryParamID,
								@MathOperationID = p.MathOperationID,
								@ParamValue = ps.ParamValue,
								@Scale = p.Scale
							FROM @prel AS p
							JOIN @pars AS ps ON ps.ParamID = p.SecondaryParamID
							WHERE ID =@id
						END
						
						IF (@id > @rl) OR (@ParamNewID != @ParamID) 
						BEGIN
							IF @ParamID != -1
							begin
								UPDATE @pars
									SET ParamValue = ROUND(@ParamCalcValue,@Scale) -- окуругляем по scale
								WHERE ParamID = @ParamID
							end
							IF (@id > @rl) BREAK;
							if @RelationParamID = @ParamID
								SET @ParamValue = @ParamCalcValue
									
							SET @ParamID = @ParamNewID;
							SET @ParamCalcValue = 0;
						END							
													
						IF @MathOperationID = 1
						BEGIN
							SET @ParamCalcValue = @ParamCalcValue + @ParamValue;	
						END
						ELSE
							IF @MathOperationID = 2
							BEGIN
								SET @ParamCalcValue = @ParamCalcValue - @ParamValue;
							END	
							ELSE
								IF @MathOperationID = 3
								BEGIN
									SET @ParamCalcValue = @ParamCalcValue * @ParamValue;
								END
															
						SET @id += 1;	
					END
				END
			END
			
			-- ПАРАМЕТРЫ МОНИТОРА
			INSERT INTO @mrel(
				MonitorParamID,
				ParamID,
				RelationParamID,
				RelationParamValue,
				OldRelationParamValue,
				MathOperationID,
				Scale	
			)		
			SELECT
				mp.MonitorParamID,
				p.ParamID,
				pr.SecondaryParamID AS RelationParamID,
				ps.ParamValue AS RelationParamValue,
				ps.OldParamValue AS OldRelationParamValue,
				pr.MathOperationID,
				pvt.Scale	
			FROM dbo.MonitorParams AS mp
			JOIN dbo.Params AS p ON p.ParamID = mp.ParameterID AND p.ParamTypeID = 2
			JOIN dbo.ParamRelations AS pr ON pr.PrimaryParamID = mp.ParameterID
			JOIN @pars AS ps ON ps.ParamID = pr.SecondaryParamID
			JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID 
			WHERE mp.MonitorID = @MonitorID AND mp.[Active] = 1 
			
			SET @rt = @@ROWCOUNT
			SELECT @id = 1,@ParamID = -1,@ParamCalcValue = 0,@OldRelationParamValue = 0; 
			IF @rt > 0
			BEGIN
				WHILE(1=1)
				BEGIN
					IF @id <= @rt
					BEGIN
						SELECT 
							@MonitorParamID = p.MonitorParamID,
							@ParamNewID = p.ParamID,
							@RelationParamID = p.RelationParamID,
							@MathOperationID = p.MathOperationID,
							@RelationParamValue = p.RelationParamValue,
							@OldRelationParamValue = IsNull(p.OldRelationParamValue,0),
							@Scale = p.Scale
						FROM @mrel AS p
						WHERE ID =@id
					END
					IF (@id > @rt) OR (@ParamNewID != @ParamID ) 
					BEGIN
						IF @ParamID != -1
						BEGIN 
							--IF @Mode = 0	
							--	UPDATE dbo.MonitorTotalParamValues
							--	SET
							--		MonitorParamValue = IsNull(MonitorParamValue,0) + ROUND(@ParamCalcValue,@Scale) -- округляем по scale
							--	WHERE MonitorParamID= @MonitorParamID
							--ELSE
							--IF @Mode IN (0,1) -- обновление измерения
								UPDATE dbo.MonitorTotalParamValues
								SET
									MonitorParamValue = IsNull(MonitorParamValue,0) + ROUND(@ParamCalcValue,@Scale) -- округляем по scale
								WHERE MonitorParamID= @MonitorParamID
							--ELSE								
							--	IF @Mode = 2 -- удаление измерения
							--		UPDATE dbo.MonitorTotalParamValues
							--		SET
							--			MonitorParamValue = IsNull(MonitorParamValue,0) - ROUND(@ParamCalcValue,@Scale)
							--		WHERE MonitorParamID= @MonitorParamID
						END;													
						IF (@id > @rt) BREAK;									
						SET @ParamID = @ParamNewID;
						SET @ParamCalcValue = 0;
					END			
					IF @MathOperationID = 1
					BEGIN
						SET @ParamCalcValue = @ParamCalcValue + (@RelationParamValue - @OldRelationParamValue);	
					END
					ELSE
						IF @MathOperationID = 2
						BEGIN
							SET @ParamCalcValue = @ParamCalcValue - (@RelationParamValue - @OldRelationParamValue);
						END	
						ELSE
							IF @MathOperationID = 3
							BEGIN
								SET @ParamCalcValue = @ParamCalcValue * (@RelationParamValue - @OldRelationParamValue);
							END
					SET @id += 1;															
				END;	
			END;		
			----------------------			
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
				WHERE ParamTypeID IN (0,1);				
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
				WHERE mp.MonitoringID = @MonitoringID AND p.ParamTypeID IN (0,1);				
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
			RETURN 0			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT != 0 
			ROLLBACK;
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();				
		RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
		RETURN 1
	END CATCH	  
END
GO
