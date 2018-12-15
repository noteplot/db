set quoted_identifier, ansi_nulls on
go

-- =============================================
-- Author:		[ab]
-- Create date: 20180204
-- Description:	Создание/редактирование/удаление группы ед.изм
-- @Mode:		0 - создание 1- изменение 2 - удаление       
-- =============================================

if object_id('[dbo].[UnitGroupSet]', 'P') is null
    exec (
             'create procedure [dbo].[UnitGroupSet] as begin return -1 end'
         )
go

alter procedure dbo.UnitGroupSet
	@UnitGroupID bigint out,
	@UnitGroupShortName nvarchar(24),
	@UnitGroupName nvarchar(48),
	@LoginID bigint,
	@Mode tinyint
as
begin
	set nocount on;
	declare @ProcName nvarchar(128) = object_name(@@PROCID);--N'dbo.UnitGroupSet';--
	
	begin try
		if @Mode not in (0, 1, 2)
		begin
		    raiserror('Некорректное значение параметра @Mode', 16, 1);
		end
		
		begin tran
		
		if @Mode = 0 -- ins
		begin
		    if exists(
		           select 1
		           from   dbo.UnitGroups (updlock)
		           where  UnitGroupShortName = @UnitGroupShortName
		                  and LoginID = @LoginID
		       )
		        raiserror('Уже есть группа с таким кратким названием!', 16, 2);				
		    
		    insert into dbo.UnitGroups
		      (
		        [UnitGroupShortName],
		        [UnitGroupName],
		        [LoginID]
		      )
		    values
		      (
		        @UnitGroupShortName,
		        @UnitGroupName,
		        @LoginID
		      )
		    set @UnitGroupID = scope_identity();
		end
		else
		if @Mode = 1
		begin
		    if @UnitGroupID is null
		        raiserror('Группа не установлена!', 16, 3);
		    if exists(
		           select 1
		           from   dbo.UnitGroups (repeatableread)
		           where  UnitGroupID != @UnitGroupID
		                  and UnitGroupShortName = @UnitGroupShortName
		                  and LoginID = @LoginID
		       )
		        raiserror('Уже есть группа с таким кратким наименованием!', 16, 4);				
		    
		    update dbo.UnitGroups
		    set    UnitGroupShortName     = @UnitGroupShortName,
		           UnitGroupName          = @UnitGroupName
		    where  UnitGroupID            = @UnitGroupID
		           and LoginID            = @LoginID
		end
		else					 
		if @Mode = 2
		begin
		    if exists(
		           select 1
		           from   dbo.Units as u(holdlock)
		           where  u.UnitGroupID = @UnitGroupID
		       )
		    begin
		        raiserror('Группа используется в ед.измерения!', 16, 5);
		    end	
		    
		    delete 
		    from   dbo.UnitGroups -- AFTER trigger
		    where  UnitGroupID = @UnitGroupID
		end
		
		commit
	end try
	begin catch
		if @@TRANCOUNT > 0
		    rollback
		
		exec [dbo].[ErrorLogSet] @LoginID = @LoginID,
		     @ProcName = @ProcName,
		     @Reraise = 1,
		     @rollback = 1;
		return 1;
	end catch
end
go

