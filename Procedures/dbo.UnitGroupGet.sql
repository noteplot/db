set quoted_identifier, ansi_nulls on
go

-- ============================================================
-- Author:		[ab]
-- Create date: 20180204
-- Description:	��������� ��������� ������ ����� ��.���������
-- ============================================================

if object_id('[dbo].[UnitGroupGet]', 'P') is null
    exec (
             'create procedure [dbo].[UnitGroupGet] as begin return -1 end'
         )
go

alter procedure [dbo].[UnitGroupGet]
	@UnitGroupID	bigint = null,
	@LoginID		bigint
as
begin
	set nocount on;
	begin try
		select u.UnitGroupID,
		       u.UnitGroupShortName,
		       u.UnitGroupName,
		       u.LoginID
		from   dbo.UnitGroups as u
		where  u.UnitGroupID = isnull(@UnitGroupID, u.UnitGroupID)
		       and u.LoginID in (0, @LoginID)
	end try
	begin catch
		if @@TRANCOUNT > 0
		    rollback
		
		declare @ProcName nvarchar(128) = object_name(@@PROCID);--N'dbo.UnitGroupGet';-- 
		exec [dbo].[ErrorLogSet] @LoginID = @LoginID,
		     @ProcName = @ProcName,
		     @Reraise = 1,
		     @rollback = 1;
		return 1;
	end catch
end
go
