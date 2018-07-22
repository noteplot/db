set quoted_identifier, ansi_nulls on
go
/*
-- =============================================
-- Author:		[ab]
-- Create date: 20170813
-- Description:	Создание/редактирование/удаление параметра
-- @ParameterRelations - xml список связанных параметров
--	<ParameterRelations>
--	  <ParameterRelation>
--		<ParameterID>4</ParameterID>
--		<MathOperationID>1</MathOperationID>
--	  </ParameterRelation>
--	  ....................
--	</ParameterRelations>'

-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================
*/
IF OBJECT_ID('[dbo].[ParameterSet]', 'P') is null
 EXEC('create procedure [dbo].[ParameterSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.ParameterSet 
	@ParameterID		BIGINT out,
	@ParamShortName		NVARCHAR(24),
	@ParamName			NVARCHAR(48),
	@ParamUnitID		BIGINT,
	@ParamValueTypeID	TINYINT,
	@ParamTypeID		TINYINT,
	@ParameterGroupID	BIGINT,
	@ParamValueMAX		DECIMAL(28,6) = NULL,
	@ParamValueMIN		DECIMAL(28,6) = NULL,
	@LoginID			BIGINT,
	@Active				BIT = 1,
	@ParameterRelations	XML = NULL, 			
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT

	DECLARE
		@ResourceLimitID INT = 2, -- кол-во параметров по логину
		@ResourceValue INT = 0,
		@ResourceLimitValue INT = 0;
						
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END
		
		IF @Mode in (0,1)
		BEGIN
			if @ParamTypeID = 0 AND @ParameterRelations IS NOT NULL 
				RAISERROR('Для данного типа связанных параметров не должно быть!',16,2);
			 
			if @ParamTypeID IN (1,2) AND @ParameterRelations IS NULL 
				RAISERROR('Для данного типа должен быть указан хотя бы один связанный параметр!',16,3);
			IF @ParamValueMAX IS NOT NULL AND @ParamValueMIN IS NOT NULL 
			BEGIN
				IF @ParamValueMAX < @ParamValueMIN 
				RAISERROR('Максимальное значение должно быть не меньше минимального!',16,4);
			END								
		END
		
		IF @Mode in (1,2)
		BEGIN 
			IF @ParameterID IS NULL
				RAISERROR('Параметр не указан!',16,5);
		END

		IF @Mode IN (0,1) AND @ParameterRelations IS NOT NULL 
		BEGIN
			declare
				@rls table (
					ParamRelationPosition INT NOT NULL IDENTITY(1,1),
					ParameterID BIGINT NOT NULL,
					MathOperationID INT  NOT NULL
				)
				INSERT INTO @rls(ParameterID, MathOperationID)	
				select 
					c.value('ParameterID[1]','bigint') AS ParameterID,
					c.value('MathOperationID[1]','tinyint') AS MathOperationID
				from 
					@ParameterRelations.nodes('/ParameterRelations/ParameterRelation') t(c)
					
			IF @@ROWCOUNT = 0
				RAISERROR('Должен быть указан хотя бы один связанный параметр!',16,6);
				
			IF EXISTS(
					SELECT 1 
					FROM @rls AS r
					WHERE r.ParameterID = @ParameterID
			)								
				RAISERROR('Связанный параметр не должен совпадать с текущим!',16,7);					

			if exists(
				SELECT 1 FROM @rls GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
			)
				RAISERROR('Связанные параметры не должны дублироваться!',16,8);
		END

		IF @Mode = 0
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.Params (nolock) WHERE ParamShortName = @ParamShortName AND LoginID = @LoginID)
				RAISERROR('Уже есть параметр с таким названием!',16,9);
		END	 

		IF @Mode = 1
		begin 
			IF EXISTS(SELECT 1 FROM dbo.Params (nolock) WHERE ParamID != @ParameterID and LoginID = @LoginID and ParamShortName = @ParamShortName )
				RAISERROR('Уже есть параметр с таким названием!',16,10);
		end		
		
		
		IF @Mode = 0 -- проверка лимитов ресурсов
		begin 
			SELECT @ResourceValue = IsNull(r.Value,0) FROM dbo.ResourceCounts(nolock) AS r WHERE r.LoginID = @LoginID AND r.ResourceLimitID = @ResourceLimitID
			SELECT @ResourceLimitValue = ResourceLimitValue from dbo.fnResourceLimitsGet (DEFAULT,@LoginID,@ResourceLimitID)
			IF @ResourceValue >= @ResourceLimitValue
			BEGIN				
				RAISERROR('Достигнут предел (%i) количества параметров для вашей учетной записи!',16,11,@ResourceLimitValue);
			end	
		end		
				
		BEGIN TRAN			
			IF @Mode in (0,1)
			BEGIN
				IF @Mode = 1
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM dbo.Params (updlock) WHERE ParamID = @ParameterID AND LoginID = @LoginID)
						RAISERROR('Указанный параметр не существует!',16,12);
				END	 
			END
			-- изменение типа параметра	
			IF @Mode = 1 AND @ParamTypeID = 0 AND (EXISTS(SELECT 1 FROM dbo.Params AS p (updlock) WHERE p.ParamID = @ParameterID AND p.ParamTypeID != @ParamTypeID))
			BEGIN
				DECLARE
					@MonitorShortName NVARCHAR(255);	
				-- ПРОВЕРКА НА МОНИТОРИНГ
				SELECT 
					@MonitorShortName = m.MonitorShortName  
				FROM dbo.MonitoringParams AS mps (updlock)
				JOIN dbo.Monitorings AS ms (holdlock) ON ms.MonitoringID = mps.MonitoringID
				JOIN dbo.Monitors AS m (holdlock) ON m.MonitorID = ms.MonitorID
				JOIN dbo.MonitorParams AS mp (holdlock) ON mp.MonitorID = m.MonitorID				 
				WHERE mps.ParamID = @ParameterID
				IF @MonitorShortName IS NOT NULL
				BEGIN
					RAISERROR('Изменить тип параметра нельзя, т. к. он используется в измерениях по монитору  %s.',16,13, @MonitorShortName);
				end	
				
				-- удаляем связанные параметры
				DELETE FROM dbo.ParamRelations
				WHERE PrimaryParamID = @ParameterID			
			END
						
			IF @Mode = 0 
			BEGIN				
				INSERT INTO dbo.Parameters(ParameterKindID,ParameterGroupID)
				VALUES(0,@ParameterGroupID)
				SET @ParameterID = SCOPE_IDENTITY();
								
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
					@ParameterID,
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
				UPDATE dbo.Parameters
				SET 					
					ParameterGroupID	= @ParameterGroupID,
					[Active]			= @Active 
				WHERE
					ParameterID			= @ParameterID 
				
				
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
				WHERE ParamID = @ParameterID						
			END
			ELSE					 
			IF @Mode = 2
			BEGIN
				exec dbo.ParameterDelete @ParameterID, @LoginID
			END		 
								
			IF @Mode IN (0,1) AND @ParameterRelations IS NOT NULL 
			BEGIN			
				MERGE dbo.ParamRelations AS t
				USING (SELECT ParameterID AS [SecondaryParamID], MathOperationID, ParamRelationPosition
				       FROM @rls) AS s 
				ON (t.PrimaryParamID = @ParameterID AND t.SecondaryParamID = s.SecondaryParamID)
				WHEN NOT MATCHED THEN
					INSERT (PrimaryParamID, SecondaryParamID,MathOperationID,ParamRelationPosition)
					VALUES (@ParameterID, s.SecondaryParamID,s.MathOperationID,s.ParamRelationPosition)
				WHEN MATCHED THEN
					UPDATE 
						SET ParamRelationPosition = s.ParamRelationPosition					
				WHEN NOT MATCHED BY SOURCE and t.PrimaryParamID = @ParameterID THEN
					DELETE; 												    	         												
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


--	@JSON				VARCHAR(MAX) = NULL,
/*	   		
@lParameter int = LEN('"ParameterID":"'),
@lMathOperationID int = LEN('"MathOperationID":"'),
@rParameterID bigint, @rMathOperationID bigint
*/
/*					
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
		RAISERROR('Не определен идентификатор связанного параметра!',16,6);	
		break;
	END;	
	set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1) 
	set @ind1 = CHARINDEX('"MathOperationID":"',@JSON,@ind2)+@lMathOperationID
	if @ind1 = 0
	BEGIN
		RAISERROR('Не указан тип математической операции!',16,7);	
		break;
	END;						
	set @ind2 = CHARINDEX('"',@JSON,@ind1);
	if @ind2 = 0
	BEGIN
		RAISERROR('Не указан идентификатор математической операции!',16,8);	
		break;
	END;						
	set @rMathOperationID  = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
	insert into @rls(ParameterID,MathOperationID)
		select @rParameterID,@rMathOperationID
	set @id += 1
END
				
IF @id = 0
	RAISERROR('Должен быть указан хотя бы один связанный параметр!',16,9);
*/
