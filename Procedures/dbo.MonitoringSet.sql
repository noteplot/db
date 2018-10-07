set quoted_identifier, ansi_nulls on
GO

/*
-- =============================================
-- Author:		[ab]
-- Create date: 20171224
-- Description:	Создание/редактирование/удаление измерения
--  @MonitoringParams - xml список связанных параметров:
	<MonitoringParams>
	  <MonitoringParam>
		<ParameterID>45</ParamID>
		
	  </MonitoringParam>
	  ...........
	</MonitoringParams>
	(MonitoringParamID,MonitorParamID,ParameterID,ParameterTypeID,ParameterValue)
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================
*/
IF OBJECT_ID('[dbo].[MonitoringSet]', 'P') is null
 EXEC('create procedure [dbo].[MonitoringSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitoringSet 
	@MonitoringID		BIGINT out,
	@MonitorID			BIGINT = NULL,
	@MonitoringDate		DATETIME2(0) = NULL,
	@MonitoringComment	NVARCHAR(255) = NULL,
	@MonitoringParams	XML = NULL,
	--@JSON				VARCHAR(MAX) = NULL,			
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
		@AllParams INT = 0,
		@ParamID BIGINT,
		@ParamNewID BIGINT,
		@MonitorParamID BIGINT,
		@RelationParamID	BIGINT,
		@MathOperationID	TINYINT,
		@ParamValue  DECIMAL(28,6),
		@ParamCalcValue  DECIMAL(28,6) = 0,
		@RelationParamValue  DECIMAL(28,6),
		@OldRelationParamValue  DECIMAL(28,6),						
		@Scale TINYINT = 0,								
		@ParameterName1 NVARCHAR(255), 
		@ParameterName2 NVARCHAR(255),
		@LoginID BIGINT;
							
	DECLARE
		@ResourceLimitID INT = 4, -- Количество измерений по монитору
		@ResourceValue INT = 0,
		@ResourceLimitValue INT = 0;
								
	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitoringSet';--
										
	BEGIN TRY
		-- ПРОВЕРКИ
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		IF @Mode = 0
		BEGIN
			IF @MonitorID IS NULL	 
				RAISERROR('Не указан шаблон измерения(монитор).',16,2);
		END							
		IF @Mode IN (0,1)
		BEGIN
			IF @Mode = 1 AND @MonitoringID IS NULL
				RAISERROR('Не указано измерение по монитору.',16,3);
				
			IF @MonitoringDate IS NULL	 
				RAISERROR('Не установлено время измерения.',16,4);
				
			IF @MonitoringParams IS NULL
				RAISERROR('Нет параметров измерения.',16,5);
				
		END
		
		IF @MonitorID IS NULL 
		BEGIN	 
			SELECT @MonitorID = MonitorID FROM dbo.Monitorings (nolock) AS mp
			WHERE mp.MonitoringID = @MonitoringID
		END

		SELECT @LoginID = LoginID FROM dbo.Monitors AS m (nolock)
		WHERE m.MonitorID = @MonitorID
		IF @LoginID IS NULL 
			RAISERROR('Не установлена учетная запись пользователя.',16,6);
		-- параметры
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
				DECLARE
					@id int = 1
					
				-- вычисляемые параметры	
				DECLARE
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
			END
				
			IF @Mode IN (0,1) 
			BEGIN				
				IF EXISTS(SELECT 1 FROM dbo.Monitorings (nolock) WHERE MonitorID = @MonitorID AND MonitoringDate =@MonitoringDate  
				AND MonitoringID != IsNull(@MonitoringID,0)) 
					RAISERROR('Уже есть измерение с такой датой и временем!',16,11);
								
				INSERT INTO @pars(MonitoringParamID,MonitorParamID,ParamID,ParamValue,ParamTypeID)	
				select 
					c.value('MonitoringParamID[1]','bigint')		AS MonitoringParamID,
					c.value('MonitorParamID[1]','bigint')			AS MonitorParamID,
					c.value('ParameterID[1]','bigint')				AS ParamID,
					c.value('ParameterValue[1]','DECIMAL(28,6)')	AS ParamValue,
					c.value('ParameterTypeID[1]','int')				AS ParamTypeID												
					--mp.ParamValue									AS OldParamValue
				FROM @MonitoringParams.nodes('/MonitoringParams/MonitoringParam') t(c)
				set @AllParams = @@ROWCOUNT; 
				IF @AllParams = 0
					RAISERROR('Нет параметров измерения!',16,7);
					
				IF EXISTS(
					SELECT 1 FROM @pars AS p
					JOIN dbo.Params AS p2 ON p2.ParamID = p.ParamID AND p2.ParamTypeID = 0
					WHERE p.ParamValue IS NULL 
				)
				BEGIN
					RAISERROR('Для параметров должно быть указано значение измерения!',16,8);	
				END
					
				IF @Mode = 0
				BEGIN
					if exists(SELECT top 1 1
					FROM @pars 
					GROUP BY ParamID
					HAVING(COUNT(1) > 1)
					)
						RAISERROR('Параметры в измерении не должны дублироваться!',16,9);				
				END	
												
			END
			
			IF @Mode = 0 -- проверка лимитов ресурсов
			begin 
				SELECT @ResourceValue = IsNull(r.Value,0) FROM dbo.ResourceCounts(nolock) AS r WHERE r.LoginID = @LoginID AND r.ResourceLimitID = @ResourceLimitID
				SELECT @ResourceLimitValue = ResourceLimitValue from dbo.fnResourceLimitsGet (DEFAULT,@LoginID,@ResourceLimitID)
				IF @ResourceValue >= @ResourceLimitValue
				BEGIN				
					RAISERROR('Достигнут предел (%i) количества измерений по монитору для вашей учетной записи!',16,10,@ResourceLimitValue);
				end	
			end		
			
			IF @Mode IN (0,1)
			BEGIN
				--left join dbo.MonitoringParams AS mp on mp.MonitoringParamID = c.value('MonitoringParamID[1]','bigint')
				BEGIN TRAN														
					IF @Mode = 1
					BEGIN
						if not exists(select 1 from dbo.Monitorings(updlock) where MonitoringID = @MonitoringID)
							RAISERROR('Данного измерения по монитору нет.',16,12);

						UPDATE p
							set OldParamValue = mp.ParamValue
						FROM @pars as p
						JOIN dbo.MonitoringParams AS mp(updlock) on mp.MonitoringParamID = p.MonitoringParamID							
					END;		
															
					INSERT INTO @parc(MonitoringParamID,MonitorParamID,ParamID,ParamValue,Scale)
					select 
						ps.MonitoringParamID,
						ps.MonitorParamID,
						ps.ParamID,
						ps.ParamValue,
						pvt.Scale
					FROM @pars AS ps						
					JOIN dbo.Params AS p (updlock) ON p.ParamID = ps.ParamID
					JOIN dbo.ParamValueTypes AS pvt ON pvt.ParamValueTypeID = p.ParamValueTypeID
					WHERE ps.ParamTypeID = 1 -- вычисляемый параметр					
					set @rc = @@ROWCOUNT
			END
			ELSE
			BEGIN -- удаление
				BEGIN TRAN
					if not exists(select 1 from dbo.Monitorings(updlock) where MonitoringID = @MonitoringID)
						RAISERROR('Данного измерения по монитору нет.',16,13);
								
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
					FROM dbo.MonitoringParams (updlock) AS mp
					JOIN dbo.Params AS p (REPEATABLEREAD) ON p.ParamID = mp.ParamID					
					WHERE mp.MonitoringID = @MonitoringID
			END					
								
			-- Расчетные параметры   - расчет значений
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
						FROM dbo.ParamRelations AS pr (REPEATABLEREAD)
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
									SET ParamValue = ROUND(@ParamCalcValue,@Scale) -- округляем по scale
								WHERE ParamID = @ParamID
							end
							IF (@id > @rl) BREAK;
							if @RelationParamID = @ParamID
								SET @ParamValue = @ParamCalcValue
									
							SET @ParamID = @ParamNewID;
							SET @ParamCalcValue = 0;
						END							
						BEGIN TRY							
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
									ELSE
										IF @MathOperationID = 4
										BEGIN
											IF (@ParamValue = 0)
											BEGIN				
												SET @ErrorMessage = 'Значение связанного параметра в операции "деление" не должно быть равно нулю!'								
												SELECT @ParameterName1 = ParamShortName FROM dbo.Params(nolock) AS p
												WHERE ParamID = @ParamID								
												SELECT @ParameterName2 = ParamShortName FROM dbo.Params(nolock) AS p
												WHERE ParamID = @RelationParamID   								
										
												IF IsNull(@ParameterName1,'') != ''  
												SET @ErrorMessage = 'Расчетный парaметр '+'"'+@ParameterName1+'" ';
												IF IsNull(@ParameterName2,'') != ''  
												SET @ErrorMessage = 'Связанный парaметр '+'"'+@ParameterName2+'" ';
												RAISERROR(@ErrorMessage,16,14)																															
											END;	
											SET @ParamCalcValue = @ParamCalcValue / @ParamValue;
										END
						END TRY
						BEGIN CATCH
							SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
							IF (ERROR_NUMBER() = 8115)
							BEGIN
								SELECT @ParameterName1 = ParamShortName FROM dbo.Params AS p
								WHERE ParamID = @ParamID								
								SELECT @ParameterName2 = ParamShortName FROM dbo.Params AS p
								WHERE ParamID = @RelationParamID   								
								   
								SET @ErrorMessage = 'Ошибка арифметического переполнения. Получаемое расчетное значение превысило предельную величину!'
								IF IsNull(@ParameterName1,'') != ''  
									SET @ErrorMessage = 'Расчетный парaметр '+'"'+@ParameterName1+'" ';
								IF IsNull(@ParameterName2,'') != ''  
									SET @ErrorMessage = 'Связанный парaметр '+'"'+@ParameterName2+'" ';
									
								RAISERROR('Значение связанного параметра в операции "деление" не должно быть равно нулю!',@ErrorSeverity,15)
							END	
							ELSE 				
								RAISERROR(@ErrorMessage,@ErrorSeverity,16)								
						END CATCH															
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
			JOIN dbo.Params AS p (REPEATABLEREAD) ON p.ParamID = mp.ParameterID AND p.ParamTypeID = 2
			JOIN dbo.ParamRelations AS pr (REPEATABLEREAD) ON pr.PrimaryParamID = mp.ParameterID
			JOIN @pars AS ps ON ps.ParamID = pr.SecondaryParamID
			JOIN dbo.ParamValueTypes AS pvt (REPEATABLEREAD) ON pvt.ParamValueTypeID = p.ParamValueTypeID 
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
					BEGIN TRY
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
								ELSE
									IF @MathOperationID = 4
									BEGIN
										IF (@RelationParamValue = 0)
										BEGIN							
											SET @ErrorMessage = 'Значение связанного параметра в операции "деление" не должно быть равно нулю!';
											SELECT @ParameterName1 = ParamShortName FROM dbo.Params(nolock) AS p
											WHERE ParamID = @ParamID								
											SELECT @ParameterName2 = ParamShortName FROM dbo.Params(nolock) AS p
											WHERE ParamID = @RelationParamID   								
										
											IF IsNull(@ParameterName1,'') != ''  
											SET @ErrorMessage = 'Расчетный парaметр '+'"'+@ParameterName1+'" ';
											IF IsNull(@ParameterName2,'') != ''  
											SET @ErrorMessage = 'Связанный парaметр '+'"'+@ParameterName2+'" ';
											RAISERROR(@ErrorMessage,16,17)											
										END;	
										SET @ParamCalcValue = @ParamCalcValue / @RelationParamValue - IIF( @OldRelationParamValue = 0,0,@ParamCalcValue / @OldRelationParamValue);
									END							
					END TRY
					BEGIN CATCH
						SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
						IF (ERROR_NUMBER() = 8115)
						BEGIN								
							SELECT @ParameterName1 = ParamShortName FROM dbo.Params(nolock) AS p
							WHERE ParamID = @ParamID								
							SELECT @ParameterName2 = ParamShortName FROM dbo.Params(nolock) AS p
							WHERE ParamID = @RelationParamID   								
								   
							SET @ErrorMessage = 'Ошибка арифметического переполнения. Получаемое расчетное значение превысило предельную величину!'
							IF IsNull(@ParameterName1,'') != ''  
								SET @ErrorMessage = 'Расчетный парaметр '+'"'+@ParameterName1+'" ';
							IF IsNull(@ParameterName2,'') != ''  
								SET @ErrorMessage = 'Связанный парaметр '+'"'+@ParameterName2+'" ';
									
							RAISERROR(@ErrorMessage,@ErrorSeverity,18)
						END	
						ELSE 				
							RAISERROR(@ErrorMessage,@ErrorSeverity,19)								
					END CATCH															
							
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
					AND  (MonitoringDate != @MonitoringDate OR IsNull(MonitoringComment,'') != IsNull(@MonitoringComment,''))
					
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
			
			-- Увеличение счетчика +1
			IF @Mode = 0
			BEGIN
				;MERGE dbo.ResourceCounts AS t
				USING (SELECT @LoginID AS LoginID, @ResourceLimitID AS ResourceLimitID) AS s
				ON (t.LoginID = s.LoginID AND t.ResourceLimitID = s.ResourceLimitID)
				WHEN MATCHED THEN 
					UPDATE
						SET t.[Value] += 1
				WHEN NOT MATCHED THEN		 
					INSERT (LoginID, ResourceLimitID,[Value])
					VALUES (s.LoginID, s.ResourceLimitID,1);					
			END						
															
			-- уменьшение счетчика
			IF @Mode = 2
				UPDATE dbo.ResourceCounts
					SET [Value] -= 1
				WHERE LoginID = @LoginID AND ResourceLimitID = @ResourceLimitID

			COMMIT
			RETURN 0			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback= 1;
		RETURN 1;
	END CATCH	  
END
GO

/*	
--JSON parsing
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
*/			
