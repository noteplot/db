set quoted_identifier, ansi_nulls on
GO

/*
-- =============================================
-- Author:		[ab]
-- Create date: 20171119
-- Description:	—оздание/редактирование/удаление монитора
   @MonitorParameters - xml список св€занных параметров:
	<MonitorParameters>
	  <MonitorParameter>
		<ParameterID>45</ParameterID>
		<MonitorParameterActive>true</MonitorParameterActive>
	  </MonitorParameter>
	  ...........
	</MonitorParameters>
-- @Mode:		0 - создание 1- изменение
-- =============================================
*/
IF OBJECT_ID('[dbo].[MonitorSet]', 'P') is null
 EXEC('create procedure [dbo].[MonitorSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.MonitorSet 
	@MonitorID			BIGINT out,
	@MonitorShortName	NVARCHAR(24),
	@MonitorName		NVARCHAR(48),
	@LoginID			BIGINT,
	@Active				BIT = 1,
	@MonitorParameters	XML = NULL,
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000);
			   		
	DECLARE				
		@ParamID BIGINT,
		@CalcParamName NVARCHAR(255),
		@ParamName NVARCHAR(255),
		@PacketName  NVARCHAR(255);
		  					
	DECLARE
		@ResourceLimitID INT = 1, -- кол-во мониторов по логину
		@ResourceValue INT = 0,
		@ResourceLimitValue INT = 0;
				  					
	DECLARE @par table (
			MonitorParamPosition INT NOT NULL IDENTITY(1,1),
			ParameterID bigint NOT NULL,
			MonitorParameterValue DECIMAL(28,6) NULL,
			Active BIT NOT NULL
		)

	DECLARE 
		@ProcName NVARCHAR(128) = OBJECT_NAME(@@PROCID);--N'dbo.MonitorSet';--
				  					
	-- —писок всех параметров монитора(включа€ пакеты)
	DECLARE @pm TABLE (
		ParamID BIGINT NOT NULL,
		ParamName NVARCHAR(255) NOT NULL,
		ParamTypeID TINYINT NOT NULL,
		PacketName NVARCHAR(255) NULL					
	)
	-- —писок расчетных параметров
	DECLARE @pcl TABLE (
		CalcParamID BIGINT,
		CalcParamName NVARCHAR(255),
		ParamID BIGINT,
		ParamName NVARCHAR(255)  					
	)
		
	BEGIN TRY
		IF @Mode NOT IN (0,1)
			RAISERROR('Ќекорректное значение параметра @Mode',16,1);	

		IF @MonitorID IS NULL AND @Mode = 1
			RAISERROR('ћонитор не определен!',16,2);
				
		IF @Mode in (0,1) and /*@JSON*/@MonitorParameters IS NULL 
			RAISERROR('ƒолжен быть указан хот€ бы один параметр!',16,3);
			 
		IF @Mode = 0
		begin
			IF EXISTS(SELECT 1 FROM dbo.Monitors (nolock) WHERE LoginID = @LoginID AND MonitorShortName = @MonitorShortName)
				RAISERROR('”же есть монитор с таким названием!',16,4);
		end;
						
		IF @Mode = 1
		begin 
			IF EXISTS(SELECT 1 FROM dbo.Monitors (nolock) WHERE MonitorID != @MonitorID and LoginID = @LoginID and MonitorShortName = @MonitorShortName )
				RAISERROR('”же есть монитор с таким названием!',16,5);
		end											
		
		IF @Mode = 0 -- проверка лимитов ресурсов
		begin 
			SELECT @ResourceValue = IsNull(r.Value,0) FROM dbo.ResourceCounts(nolock) AS r WHERE r.LoginID = @LoginID AND r.ResourceLimitID = @ResourceLimitID
			SELECT @ResourceLimitValue = ResourceLimitValue from dbo.fnResourceLimitsGet (DEFAULT,@LoginID,@ResourceLimitID)
			IF @ResourceValue >= @ResourceLimitValue
			BEGIN				
				RAISERROR('ƒостигнут предел (%i) количества мониторов дл€ вашей учетной записи!',16,6,@ResourceLimitValue);
			end	
		end		
			
		BEGIN TRAN
			IF @Mode = 1
			begin 
				IF NOT EXISTS(SELECT 1 FROM dbo.Monitors(updlock) AS m WHERE m.MonitorID = @MonitorID)
					RAISERROR('ƒанного монитора нет!',16,7);
			end		

			IF @Mode in (0,1)
			BEGIN			
				INSERT INTO @par(ParameterID, MonitorParameterValue, Active)	
				select 
					c.value('ParameterID[1]','bigint') AS ParameterID,
					IIF(p.ParamID IS NULL, NULL, c.value('MonitorParameterValue[1]','DECIMAL(28,6)')) AS MonitorParameterValue,
					c.value('MonitorParameterActive[1]','bit') AS Active
				from 
					@MonitorParameters.nodes('/MonitorParameters/MonitorParameter') t(c)
				LEFT JOIN dbo.Params AS p (REPEATABLEREAD) ON p.ParamID = c.value('ParameterID[1]','bigint')
				AND p.ParamTypeID = 2 -- параметр монитора 											
					
				IF @@ROWCOUNT = 0	
					RAISERROR('ƒолжен быть указан хот€ бы один параметр!',16,8);
									
				-- —писок всех параметров монитора(включа€ пакеты)
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
					JOIN dbo.Packets AS pt (REPEATABLEREAD) ON pt.PacketID = p.ParameterID
					JOIN dbo.PacketParams AS pp (REPEATABLEREAD) ON pp.PacketID = pt.PacketID				
					JOIN dbo.Params AS pm (REPEATABLEREAD) ON pm.ParamID = pp.ParamID
				) AS p

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
																		
					RAISERROR(@ErrorMessage,16,9); 
				END
				
				-- ѕроверка корректности расчетных параметров								
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
				JOIN dbo.Params AS p (REPEATABLEREAD) ON p.ParamID = pm.ParamID AND p.ParamTypeID IN (1,2)
				JOIN dbo.ParamRelations AS pr (REPEATABLEREAD) ON pr.PrimaryParamID = pm.ParamID
				JOIN dbo.Params AS pm2 (REPEATABLEREAD) ON pm2.ParamID = pr.SecondaryParamID				  					
				
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
					RAISERROR(@ErrorMessage,16,10); 
				END				 				
				
				-- проверка на существование измерений по монитору
				IF @Mode = 1
				BEGIN
					IF EXISTS(
						SELECT 1 FROM dbo.MonitoringParams AS mps (REPEATABLEREAD) 
						JOIN dbo.Monitorings AS m (REPEATABLEREAD) ON m.MonitoringID = mps.MonitoringID AND m.MonitorID = @MonitorID
						--JOIN dbo.MonitorParams AS mp ON mp.MonitorParamID = mps.MonitorParamID AND mp.MonitorID = m.MonitorID
						JOIN (
							SELECT mp.ParameterID 
							FROM dbo.MonitorParams AS mp (REPEATABLEREAD)
							JOIN dbo.Monitors AS m (REPEATABLEREAD) ON m.MonitorID = mp.MonitorID AND m.MonitorID = @MonitorID
							EXCEPT
							SELECT psm.ParameterID
							FROM @par AS psm							
						) AS prm ON prm.ParameterID = mps.MonitorParamID--mp.ParameterID
					)						 
					BEGIN		
						set @ErrorMessage = '»з шаблона измерений нельз€ удалить параметр, если были проведены измерени€. ƒл€ исключени€ параметра из измерений достаточно убрать признак доступности параметра.';
						RAISERROR(@ErrorMessage,16,11); 
					END
				END
			END
									
			IF @Mode = 0 
			BEGIN					
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
				UPDATE dbo.Monitors
				SET
					MonitorShortName	= @MonitorShortName,
					MonitorName			= @MonitorName,
					Active				= @Active
				WHERE 
					MonitorID = @MonitorID			
					AND LoginID	= @LoginID 				
			END
				
			IF @Mode IN (0,1) AND /*@JSON*/@MonitorParameters IS NOT NULL 
			BEGIN
				
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
			-- ”величение счетчика +1
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
					 					
			COMMIT			
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK 
		EXEC [dbo].[ErrorLogSet] @LoginID = @LoginID, @ProcName = @ProcName, @Reraise = 1, @rollback = 1;
		RETURN 1;	
	END CATCH	  
END
GO


/*	
--@JSON				VARCHAR(MAX) = NULL,				 
--@lParameter int = LEN('"ParameterID":"'),
--@lMonitorParameterValue int = LEN('"MonitorParameterValue":"'),
--@lMonitorParameterActive int = LEN('"MonitorParameterActive":"'),
--@rParameterID BIGINT,
--@rMonitorParameterValue DECIMAL(28,6), 
--@rMonitorParameterActive BIT,
--@comma char(1) = ',',@point char(1) = '.';
	
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
*/
