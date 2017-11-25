-- =============================================
-- Author:		[ab]
-- Create date: 20171119
-- Description:	Создание/редактирование/удаление монитора
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

IF OBJECT_ID('[dbo].[MonitorSet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorSet 
	@MonitorID			BIGINT out,
	@MonitorShortName	NVARCHAR(24),
	@MonitorName		NVARCHAR(48),
	@LoginID			BIGINT,
	@Active				BIT = 1,
	@JSON				VARCHAR(MAX) = NULL,			
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT,	   		
		@lParameter int = LEN('"ParameterID":"'),
		@lMonitorParameterValue int = LEN('"MonitorParameterValue":"'),
		@lMonitorParameterActive int = LEN('"MonitorParameterActive":"'),
		@rParameterID BIGINT,
		@rMonitorParameterValue DECIMAL(28,6), 
		@rMonitorParameterActive BIT
		
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode in (0,1) and @JSON IS NULL 
				RAISERROR('Должен быть указан хотя бы один параметр!',16,2);
			
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Monitors WHERE LoginID = @LoginID AND MonitorShortName = @MonitorShortName)
					RAISERROR('Уже есть монитор с таким названием!',16,3);
					
				INSERT INTO dbo.Monitors
				(
					MonitorShortName,
					MonitorName,
					[Active],
					LoginID
				)
				VALUES
				(
					@MonitorShortName,
					@MonitorName,
					@Active,
					@LoginID
				)
				
				SET @MonitorID = SCOPE_IDENTITY();																	
			END
			ELSE
			IF @Mode = 1
			BEGIN
				IF @MonitorID IS NULL
					RAISERROR('Монитор не определен!',16,4);
				IF EXISTS(SELECT 1 FROM dbo.Monitors WHERE MonitorID != @MonitorID and LoginID = @LoginID and MonitorShortName = @MonitorShortName )
					RAISERROR('Уже есть монитор с таким названием!',16,5);				
				
				UPDATE dbo.Monitors
				SET
					MonitorShortName	= @MonitorShortName,
					MonitorName			= @MonitorName,
					Active				= @Active
				WHERE 
					MonitorID = @MonitorID			
					AND LoginID	= @LoginID 				
			END
			ELSE					 
			IF @Mode = 2
				DELETE FROM dbo.Monitors	-- AFTER trigger
				WHERE 	
					 MonitorID = @MonitorID AND 
					 LoginID = @LoginID
			
			IF @Mode IN (0,1) AND @JSON IS NOT NULL 
			BEGIN
				declare
					@par table (
						MonitorParamPosition INT NOT NULL IDENTITY(1,1),
						ParameterID bigint NOT NULL,
						MonitorParameterValue DECIMAL(28,6) NULL,
						Active BIT NOT NULL
					)
				declare		
					@ind1 bigint=0, @ind2 bigint=0, @id int = 0

				set @JSON = REPLACE(REPLACE(REPLACE(REPLACE(@JSON, char(10), ''),CHAR(13),''),CHAR(9),''),CHAR(32),'');
				while(1=1)
				begin
					set @ind1 = CHARINDEX('"ParameterID":"',@JSON,@ind1)
					if @ind1 = 0
						break;
					set @ind1 += @lParameter
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Не определен идентификатор параметра!',16,6);	
						break;
					END;	
					set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1) 
					--
					set @ind1 = CHARINDEX('"MonitorParameterValue":"',@JSON,@ind2)+@lMonitorParameterValue
					if @ind1 = 0
					BEGIN
						RAISERROR('Не указано значение параметра!',16,7);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Нет данных по значению параметра!',16,8);	
						break;
					END;					
					set @rMonitorParameterValue  = nullif(SUBSTRING(@JSON,@ind1,@ind2-@ind1),'');
					--
					set @ind1 = CHARINDEX('"MonitorParameterActive":"',@JSON,@ind2)+@lMonitorParameterActive
					if @ind1 = 0
					BEGIN
						RAISERROR('Не указан признак достyпности параметра!',16,7);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Нет данных по достyпности параметра!',16,8);	
						break;
					END;
					set @rMonitorParameterActive  = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
					
					insert into @par(ParameterID,MonitorParameterValue,[Active])
						select @rParameterID,@rMonitorParameterValue,@rMonitorParameterActive
												
					set @id += 1
				END
	
				IF @id = 0
					RAISERROR('Должен быть указан хотя бы один параметр!',16,9);
														
				if exists(SELECT top 1 1
				FROM @par 
				GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
				)
					RAISERROR('Параметры не должны дублироваться!',16,12);
				
				MERGE dbo.MonitorParams AS t
				USING (SELECT @MonitorID as MonitorID, ParameterID, Active, MonitorParamPosition FROM @par) AS s 
				ON (t.MonitorID = s.MonitorID AND t.ParameterID = s.ParameterID)
				WHEN NOT MATCHED THEN
					INSERT (MonitorID, ParameterID,MonitorParamPosition,Active)
					VALUES (@MonitorID, s.ParameterID,s.MonitorParamPosition,s.Active)					
				WHEN NOT MATCHED BY SOURCE AND t.MonitorID = @MonitorID  THEN
					DELETE -- TODO: проверять на монитор
				WHEN MATCHED THEN
					UPDATE 
						SET MonitorParamPosition = s.MonitorParamPosition,[Active] = s.[Active];
						
				-- значение итоговых значений
				MERGE dbo.MonitorTotalParamValues AS t
				USING (
					SELECT 
						mp.MonitorParamID as MonitorParamID,
						p.MonitorParameterValue AS MonitorParamValue 						 
				       FROM @par AS p
				       JOIN dbo.MonitorParams AS mp ON mp.MonitorID = @MonitorID 
				       AND mp.ParameterID = p.ParameterID
				       JOIN dbo.Params AS p2 ON p2.ParamID = p.ParameterID AND p2.ParamTypeID = 2 
				) AS s ON (t.MonitorParamID = s.MonitorParamID)
				WHEN MATCHED THEN 
					UPDATE
						SET t.MonitorParamValue = s.MonitorParamValue
				WHEN NOT MATCHED THEN		 
					INSERT (MonitorParamID, MonitorParamValue)
					VALUES (s.MonitorParamID, s.MonitorParamValue);					
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
