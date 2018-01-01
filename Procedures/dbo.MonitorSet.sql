-- =============================================
-- Author:		[ab]
-- Create date: 20171119
-- Description:	—оздание/редактирование/удаление монитора
-- @Mode:		0 - создание 1- изменение
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
		@rMonitorParameterActive BIT,
		@comma char(1) = ',',@point char(1) = '.';
	DECLARE				
		@ParamID BIGINT,
		@CalcParamName NVARCHAR(255),
		@ParamName NVARCHAR(255),
		@PacketName  NVARCHAR(255);  					
		
	BEGIN TRY
		IF @Mode NOT IN (0,1)
		BEGIN
			RAISERROR('Ќекорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode in (0,1) and @JSON IS NULL 
				RAISERROR('ƒолжен быть указан хот€ бы один параметр!',16,2);
			
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Monitors WHERE LoginID = @LoginID AND MonitorShortName = @MonitorShortName)
					RAISERROR('”же есть монитор с таким названием!',16,3);
					
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
					RAISERROR('ћонитор не определен!',16,4);
				IF EXISTS(SELECT 1 FROM dbo.Monitors WHERE MonitorID != @MonitorID and LoginID = @LoginID and MonitorShortName = @MonitorShortName )
					RAISERROR('”же есть монитор с таким названием!',16,5);				
				
				UPDATE dbo.Monitors
				SET
					MonitorShortName	= @MonitorShortName,
					MonitorName			= @MonitorName,
					Active				= @Active
				WHERE 
					MonitorID = @MonitorID			
					AND LoginID	= @LoginID 				
			END
				
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
						RAISERROR('Ќе определен идентификатор параметра!',16,6);	
						break;
					END;	
					set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1) 
					--
					set @ind1 = CHARINDEX('"MonitorParameterValue":"',@JSON,@ind2)+@lMonitorParameterValue
					if @ind1 = 0
					BEGIN
						RAISERROR('Ќе указано значение параметра!',16,7);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Ќет данных по значению параметра!',16,8);	
						break;
					END;					
					set @rMonitorParameterValue  = REPLACE(nullif(SUBSTRING(@JSON,@ind1,@ind2-@ind1),''),@comma,@point);
					--
					set @ind1 = CHARINDEX('"MonitorParameterActive":"',@JSON,@ind2)+@lMonitorParameterActive
					if @ind1 = 0
					BEGIN
						RAISERROR('Ќе указан признак достyпности параметра!',16,9);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Ќет данных по достyпности параметра!',16,10);	
						break;
					END;
					set @rMonitorParameterActive  = SUBSTRING(@JSON,@ind1,@ind2-@ind1);
										
					insert into @par(ParameterID,MonitorParameterValue,[Active])
						select @rParameterID,@rMonitorParameterValue,@rMonitorParameterActive
												
					set @id += 1
				END
	
				IF @id = 0
					RAISERROR('ƒолжен быть указан хот€ бы один параметр!',16,11);
/*														
				if exists(SELECT top 1 1
				FROM @par 
				GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
				)
					RAISERROR('ѕараметры не должны дублироватьс€!',16,12);
*/				
				-- —писок всех параметров монитора(вклю€а€ пакеты)
				DECLARE @pm TABLE (
					ParamID BIGINT NOT NULL,
					ParamName NVARCHAR(255) NOT NULL,
					ParamTypeID TINYINT NOT NULL,
					PacketName NVARCHAR(255) NULL					
				)
				INSERT INTO @pm
				SELECT
					p.ParamID,
					p.ParamName,
					p.ParamTypeID,
					p.PacketName
				FROM(
					SELECT 
						pm.ParamID,
						pm.ParamShortName AS ParamName,
						pm.ParamTypeID,
						PacketName = null
					FROM @par AS p
					JOIN dbo.Params AS pm ON pm.ParamID = p.ParameterID
					UNION ALL -- из пакетов
					SELECT 
						pm.ParamID,
						pm.ParamShortName AS ParamName,
						pm.ParamTypeID,
						PacketName = pt.PacketShortName
					FROM @par AS p
					JOIN dbo.Packets AS pt ON pt.PacketID = p.ParameterID
					JOIN dbo.PacketParams AS pp ON pp.PacketID = pt.PacketID				
					JOIN dbo.Params AS pm ON pm.ParamID = pp.ParamID
				) AS p
/*								
				if exists(SELECT top 1 1
				FROM @pm 
				GROUP BY ParamID
				HAVING(COUNT(1) > 1)
				)				
					RAISERROR('ѕараметры не должны дублироватьс€!',16,12);
*/				
/*
				select top 1 @ParamName = ParamName 
				FROM @pm
				GROUP BY ParamID,ParamName
				HAVING(COUNT(1) > 1)
*/
				select top 1 @ParamID = ParamID 
				FROM @pm
				GROUP BY ParamID
				HAVING(COUNT(1) > 1)
				
				IF @@ROWCOUNT > 0 
				BEGIN
					SELECT TOP 1 
						@ParamName = ParamName,
						@PacketName = PacketName					
					FROM @pm
					WHERE ParamID = @ParamID
					ORDER BY PacketName Desc 
					set @ErrorMessage = 'ѕараметры не должны дублироватьс€! ';
					
					IF @PacketName IS NOT NULL
						set @ErrorMessage += 'см.парaметр "'+@ParamName+'" пакет "'+@PacketName+'".'
					ELSE	
						set @ErrorMessage += 'см.парaметр "'+@ParamName+'".';
																		
					RAISERROR(@ErrorMessage,16,12); 
				END
				
				-- ѕроверка корректности расчетных параметров
				DECLARE @pcl TABLE (
					CalcParamID BIGINT,
					CalcParamName NVARCHAR(255),
					ParamID BIGINT,
					ParamName NVARCHAR(255)  					
				)
								
				INSERT INTO @pcl(
				    CalcParamID,
				    CalcParamName,
				    ParamID,
				    ParamName
				  )			
				SELECT
				    pr.PrimaryParamID AS CalcParamID,
				    pm.ParamName AS CalcParamName,
					pr.SecondaryParamID AS ParamID,
					pm2.ParamShortName  AS ParamName 
				FROM @pm AS pm
				JOIN dbo.Params AS p ON p.ParamID = pm.ParamID AND p.ParamTypeID IN (1,2)
				JOIN dbo.ParamRelations AS pr ON pr.PrimaryParamID = pm.ParamID
				JOIN dbo.Params AS pm2 ON pm2.ParamID = pr.SecondaryParamID				  					
				
				SELECT TOP 1 
					@CalcParamName = pcl.CalcParamName,
					@ParamName = pcl.ParamName					
				FROM @pcl AS pcl
				LEFT JOIN @pm AS pm ON pm.ParamID = pcl.ParamID
				WHERE pm.ParamID IS NULL  	  					
				IF @@rowcount != 0
				BEGIN
					set @ErrorMessage = 'ƒл€ расчетных(итоговых) параметров в мониторе должны быть указаны все параметры, которые используютс€ дл€ их расчета.';
					set @ErrorMessage += ' ¬ частности, дл€ парaметра "'+@CalcParamName+'" должен быть указан параметр "'+@ParamName+'".';
					RAISERROR(@ErrorMessage,16,13); 
				END				 				
				
				-- проверка на существование измерений по монитору
				IF @Mode = 1
				BEGIN
					IF EXISTS(
						SELECT 1 FROM dbo.MonitoringParams AS mps
						JOIN dbo.Monitorings AS m ON m.MonitoringID = mps.MonitoringID AND m.MonitorID = @MonitorID
						JOIN dbo.MonitorParams AS mp ON mp.MonitorParamID = mps.MonitorParamID AND mp.MonitorID = m.MonitorID)						 
					BEGIN						 
						IF EXISTS(
							SELECT TOP 1 1 FROM dbo.MonitorParams AS mp
							LEFT JOIN @par AS pr ON pr.ParameterID = mp.ParameterID
							WHERE  mp.MonitorID = @MonitorID AND pr.ParameterID IS NULL
							)	
						BEGIN
							set @ErrorMessage = '»з шаблона измерений нельз€ удалить параметр, если были проведены измерени€. ƒл€ исключени€ параметра из измерений достаточно убрать признак доступности параметра.';
							RAISERROR(@ErrorMessage,16,14); 
						END
					END
				END
				
				-- значение итоговых значений
				;WITH vls as (
					select v.*, mp.MonitorID from dbo.MonitorTotalParamValues AS v
					JOIN dbo.MonitorParams AS mp ON mp.MonitorID = @MonitorID
					AND mp.MonitorParamID = v.MonitorParamID
				)			
				MERGE vls AS t
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
					VALUES (s.MonitorParamID, s.MonitorParamValue)					
				WHEN NOT MATCHED by source AND t.MonitorID = @MonitorID THEN
					DELETE; 
				
				MERGE dbo.MonitorParams AS t
				USING (SELECT @MonitorID as MonitorID, ParameterID, Active, MonitorParamPosition FROM @par) AS s 
				ON (t.MonitorID = s.MonitorID AND t.ParameterID = s.ParameterID)
				WHEN NOT MATCHED THEN
					INSERT (MonitorID, ParameterID,MonitorParamPosition,Active)
					VALUES (@MonitorID, s.ParameterID,s.MonitorParamPosition,s.Active)					
				WHEN NOT MATCHED BY SOURCE AND t.MonitorID = @MonitorID  THEN
					DELETE -- TODO: провер€ть на монитор
				WHEN MATCHED THEN
					UPDATE 
						SET MonitorParamPosition = s.MonitorParamPosition,[Active] = s.[Active];
				
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
