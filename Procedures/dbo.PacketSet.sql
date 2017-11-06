-- =============================================
-- Author:		[ab]
-- Create date: 20171028
-- Description:	��������/��������������/�������� ������
-- @Mode:		0 - �������� 1- ��������� 2 - ��������       
-- =============================================

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
		@lPacketParameterActive int = LEN('"PacketParameterActive":"'),
		@rParameterID BIGINT,@rPacketParameterActive BIT
		
	BEGIN TRY
		IF @Mode NOT IN (0,1,2)
		BEGIN
			RAISERROR('������������ �������� ��������� @Mode',16,1);	
		END
		BEGIN TRAN
			IF @Mode in (0,1) and @JSON IS NULL 
				RAISERROR('������ ���� ������ ���� �� ���� ��������!',16,2);
			
			IF @Mode = 0 
			BEGIN
				IF EXISTS(SELECT 1 FROM dbo.Packets WHERE LoginID = @LoginID AND PacketShortName = @PacketShortName)
					RAISERROR('��� ���� ����� � ����� ���������!',16,3);				
				
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
				IF @PacketID IS NULL
					RAISERROR('����� �� ���������!',16,4);
				IF EXISTS(SELECT 1 FROM dbo.Packets WHERE PacketID != @PacketID and LoginID = @LoginID and PacketShortName = @PacketShortName )
					RAISERROR('��� ���� ����� � ����� ���������!',16,5);

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
				DELETE FROM dbo.Packets	-- AFTER trigger
				WHERE 	
					 PacketID = @PacketID AND 
					 LoginID = @LoginID
			
			IF @Mode IN (0,1) AND @JSON IS NOT NULL 
			BEGIN
				declare
					@rls table (
						PacketParamPosition INT NOT NULL IDENTITY(1,1),
						ParameterID bigint NOT NULL,
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
						RAISERROR('�� ��������� ������������� ���������!',16,6);	
						break;
					END;	
					set @rParameterID = SUBSTRING(@JSON,@ind1,@ind2-@ind1) 
					set @ind1 = CHARINDEX('"PacketParameterActive":"',@JSON,@ind2)+@lPacketParameterActive
					if @ind1 = 0
					BEGIN
						RAISERROR('�� ������ ������� ����y������ ���������!',16,7);	
						break;
					END;						
					set @ind2 = CHARINDEX('"',@JSON,@ind1);
					if @ind2 = 0
					BEGIN
						RAISERROR('��� ������ �� ����y������ ���������!',16,8);	
						break;
					END;						
					set @rPacketParameterActive  = SUBSTRING(@JSON,@ind1,@ind2-@ind1)
					insert into @rls(ParameterID,Active)
						select @rParameterID,@rPacketParameterActive						
					set @id += 1
				END
				
				IF @id = 0
					RAISERROR('������ ���� ������ ���� �� ���� ��������!',16,9);
														
				if exists(SELECT top 1 1
				FROM @rls 
				GROUP BY ParameterID
				HAVING(COUNT(1) > 1)
				)
					RAISERROR('��������� �� ������ �������������!',16,12);
				
				MERGE dbo.PacketParams AS t
				USING (SELECT @PacketID as PacketID, ParameterID, Active,PacketParamPosition FROM @rls) AS s 
				ON (t.PacketID = s.PacketID AND t.ParamID = s.ParameterID)
				WHEN NOT MATCHED THEN
					INSERT (PacketID, ParamID,PacketParamPosition)
					VALUES (@PacketID, s.ParameterID,s.PacketParamPosition)					
				WHEN NOT MATCHED BY SOURCE AND t.PacketID = @PacketID  THEN
					DELETE -- TODO: ��������� �� �������
				WHEN MATCHED THEN
					UPDATE 
						SET PacketParamPosition = s.PacketParamPosition,[Active] = s.[Active];

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
