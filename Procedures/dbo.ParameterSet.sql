set quoted_identifier, ansi_nulls on
go
/*
-- =============================================
-- Author:		[ab]
-- Create date: 20170813
-- Description:	—оздание/редактирование/удаление параметра
-- @ParameterRelations - xml список св€занных параметров
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
--	@JSON				VARCHAR(MAX) = NULL,
	@ParameterRelations	XML = NULL, 			
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT,	   		
		@lParameter int = LEN('"ParameterID":"'),
		@lMathOperationID int = LEN('"MathOperationID":"'),
		@rParameterID bigint, @rMathOperationID bigint
		
						
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Ќекорректное значение параметра @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode in (0,1) and @ParamTypeID IN (1,2) AND /*@JSON*/@ParameterRelations IS NULL 
				RAISERROR('ƒолжен быть указан хот€ бы один св€занный параметр дл€ вычислени€ значени€!',16,2);
			-- изменение типа параметра	
			IF @Mode = 1 AND @ParamTypeID = 0 AND (EXISTS(SELECT 1 FROM dbo.Params AS p (updlock) WHERE p.ParamID = @ParameterID AND p.ParamTypeID != @ParamTypeID))
			BEGIN
				-- удал€ем св€занные параметры
				DELETE FROM dbo.ParamRelations
				WHERE PrimaryParamID = @ParameterID			
			END
			
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Params (updlock) WHERE ParamShortName = @ParamShortName AND LoginID = @LoginID)
					RAISERROR('”же есть параметр с таким названием!',16,3);				
				
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
				IF @ParameterID IS NULL
					RAISERROR('ѕараметр не установлен!',16,4);
				IF EXISTS(SELECT 1 FROM dbo.Params WHERE ParamID != @ParameterID and ParamShortName = @ParamShortName AND LoginID = @LoginID)
					RAISERROR('”же есть параметр с таким названием!',16,5);
				IF @ParamValueMAX IS NOT NULL AND @ParamValueMIN IS NOT NULL 
				BEGIN
					IF @ParamValueMAX <= @ParamValueMIN 
					RAISERROR('ћаксимальное значение должно быть больше минимального!',16,5);
				END
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
				DELETE FROM dbo.Params	-- AFTER trigger
				WHERE 	
					 ParamID = @ParameterID
					 AND LoginID = @LoginID
			
			IF @Mode IN (0,1) AND /*@JSON*/@ParameterRelations IS NOT NULL 
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
						c.value('MathOperationID[1]','bigint') AS MathOperationID
					from 
						@ParameterRelations.nodes('/ParameterRelations/ParameterRelation') t(c)
					
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
						RAISERROR('Ќе определен идентификатор св€занного параметра!',16,6);	
						break;
					END;	
					set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1) 
					set @ind1 = CHARINDEX('"MathOperationID":"',@JSON,@ind2)+@lMathOperationID
					if @ind1 = 0
					BEGIN
						RAISERROR('Ќе указан тип математической операции!',16,7);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('Ќе указан идентификатор математической операции!',16,8);	
						break;
					END;						
					set @rMathOperationID  = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
					insert into @rls(ParameterID,MathOperationID)
						select @rParameterID,@rMathOperationID
					set @id += 1
				END
				
				IF @id = 0
					RAISERROR('ƒолжен быть указан хот€ бы один св€занный параметр!',16,9);
				*/
				IF @@ROWCOUNT = 0
					RAISERROR('ƒолжен быть указан хот€ бы один св€занный параметр!',16,9);
				
				IF EXISTS(
						SELECT 1 
						FROM @rls AS r
						WHERE r.ParameterID = @ParameterID
				)								
					RAISERROR('—в€занный параметр не должен совпадать с текущим!',16,10);					
/*				
				IF EXISTS(
						SELECT 1 
						FROM @rls AS r
						JOIN dbo.Params AS p ON p.ParamID = r.ParameterID
						AND p.ParamTypeID != 0
				)								
					RAISERROR('—в€занные параметры должны быть простого типа!',16,11);					
*/										
				if exists(SELECT top 1 1
				FROM @rls 
				GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
				)
					RAISERROR('—в€занные параметры не должны дублироватьс€!',16,12);
			
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
