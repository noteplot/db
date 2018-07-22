set quoted_identifier, ansi_nulls on
go
/*
-- =============================================
-- Author:		[ab]
-- Create date: 20171028
-- Description:	Создание/редактирование/удаление пакета
   @PacketParameters - xml список связанных параметров:
	<PacketParameters>
	  <PacketParameter>
		<ParameterID>4</ParameterID>
		<PacketParameterActive>1</PacketParameterActive>
	  </PacketParameter>
	  ....................
	</PacketParameters>'

   @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================
*/
IF OBJECT_ID('[dbo].[PacketSet]', 'P') is null
 EXEC('create procedure [dbo].[PacketSet] as begin return -1 end')
GO

ALTER PROCEDURE dbo.PacketSet 
	@PacketID			BIGINT out,
	@PacketShortName	NVARCHAR(24),
	@PacketName			NVARCHAR(48),
	@ParameterGroupID	BIGINT,
	@LoginID			BIGINT,
	@Active				BIT = 1,
	@PacketParameters	XML = NULL,
	@Mode				TINYINT	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,	
		@ErrorState INT	   		

	DECLARE
		@rls table (
			PacketParamPosition INT NOT NULL IDENTITY(1,1),
			ParameterID bigint NOT NULL,
			Active BIT NOT NULL
		)
		
	DECLARE
		@ResourceLimitID INT = 3, -- кол-во пакетов по логину
		@ResourceValue INT = 0,
		@ResourceLimitValue INT = 0;
		
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('Некорректное значение параметра @Mode',16,1);	
		END

		IF @Mode in (1,2)
		BEGIN
			IF @PacketID IS NULL
				RAISERROR('Пакет не определен!',16,2);
		END			

		IF @Mode in (0,1) 
		BEGIN 
			IF @PacketParameters IS NULL
				RAISERROR('Должен быть указан хотя бы один параметр!',16,3);
				
				INSERT INTO @rls(ParameterID, Active)	
				select 
					c.value('ParameterID[1]','bigint') AS ParameterID,
					c.value('PacketParameterActive[1]','bit') AS Active
				from 
					@PacketParameters.nodes('/PacketParameters/PacketParameter') t(c)					
									
			IF @@ROWCOUNT = 0
				RAISERROR('Должен быть указан хотя бы один параметр!',16,4);
														
			if exists(SELECT 1
				FROM @rls 
				GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
			)
				RAISERROR('Параметры не должны дублироваться!',16,5);
				
		END

		IF @Mode = 0 
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.Packets (nolock) WHERE LoginID = @LoginID AND PacketShortName = @PacketShortName)
				RAISERROR('Уже есть пакет с таким названием!',16,6);				
		END		

		IF @Mode = 0 -- проверка лимитов ресурсов
		begin 
			SELECT @ResourceValue = IsNull(r.Value,0) FROM dbo.ResourceCounts(nolock) AS r WHERE r.LoginID = @LoginID AND r.ResourceLimitID = @ResourceLimitID
			SELECT @ResourceLimitValue = ResourceLimitValue from dbo.fnResourceLimitsGet (DEFAULT,@LoginID,@ResourceLimitID)
			IF @ResourceValue >= @ResourceLimitValue
			BEGIN				
				RAISERROR('Достигнут предел (%i) количества пакетов для вашей учетной записи!',16,7,@ResourceLimitValue);
			end	
		end		

		BEGIN TRAN
			IF @Mode in (1,2)
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM dbo.Packets (updlock) WHERE PacketID = @PacketID)
					RAISERROR('Такого пакета нет!',16,8);
			END;
				
			IF @Mode = 0 
			BEGIN				
				INSERT INTO dbo.Parameters(ParameterKindID,ParameterGroupID)
				VALUES(1,@ParameterGroupID)
				SET @PacketID = SCOPE_IDENTITY();
								
				INSERT INTO dbo.Packets
				(			
					[PacketID],
					[PacketShortName],
					[PacketName],
					[LoginID]
				)
				VALUES
				(
					@PacketID,
					@PacketShortName,
					@PacketName,
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
					ParameterID			= @PacketID 
				
				
				UPDATE dbo.Packets						
				SET
					PacketShortName		= @PacketShortName,
					PacketName			= @PacketName,
					LoginID				= @LoginID 	
				WHERE PacketID = @PacketID						
			END
			ELSE					 
				IF @Mode = 2
						exec dbo.PacketDelete @PacketID, @LoginID
									
			IF @Mode IN (0,1) AND @PacketParameters IS NOT NULL 
			BEGIN									
				MERGE dbo.PacketParams AS t
				USING (SELECT @PacketID as PacketID, ParameterID, Active,PacketParamPosition FROM @rls) AS s 
				ON (t.PacketID = s.PacketID AND t.ParamID = s.ParameterID)
				WHEN NOT MATCHED THEN
					INSERT (PacketID, ParamID,PacketParamPosition)
					VALUES (@PacketID, s.ParameterID,s.PacketParamPosition)					
				WHEN NOT MATCHED BY SOURCE AND t.PacketID = @PacketID  THEN
					DELETE -- TODO: проверять на монитор
				WHEN MATCHED THEN
					UPDATE 
						SET PacketParamPosition = s.PacketParamPosition,[Active] = s.[Active];

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

/*
--@JSON				VARCHAR(MAX) = NULL,			
--@lParameter int = LEN('"ParameterID":"'),
--@lPacketParameterActive int = LEN('"PacketParameterActive":"'),
--@rParameterID BIGINT,@rPacketParameterActive BIT
 	
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
	set @ind1 = CHARINDEX('"PacketParameterActive":"',@JSON,@ind2)+@lPacketParameterActive
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
	set @rPacketParameterActive  = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
	insert into @rls(ParameterID,Active)
		select @rParameterID,@rPacketParameterActive						
	set @id += 1
END
				
IF @id = 0
	RAISERROR('Должен быть указан хотя бы один параметр!',16,9);
*/
