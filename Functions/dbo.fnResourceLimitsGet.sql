
if OBJECT_ID('dbo.fnResourceLimitsGet') is null
 exec('create function dbo.fnResourceLimitsGet(@RoleID bigint, @LoginID bigint) RETURNS TABLE AS RETURN (select 1 as ''1'')')
GO

-- =============================================
-- Author:		[ab]
-- Create date: 25.03.2018
-- Description:	Функция получения лимитов
-- =============================================
ALTER FUNCTION dbo.fnResourceLimitsGet 
(
	@RoleID INT = NULL,
	@LoginID BIGINT = NULL 
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		l.ResourceLimitID,
		ResourceLimitValue =
		IIF(ll.ResourceLimitValue IS NOT NULL,ll.ResourceLimitValue,IIF(rl.ResourceLimitValue IS NOT NULL,rl.ResourceLimitValue,l.ResourceLimitValue)) 
		 /*
			case
				when rl.ResourceLimitValue IS null then l.ResourceLimitValue
				else rl.ResourceLimitValue
			end
		*/
		--RoleID = rl.RoleID	
	from dbo.ResourceLimits as l
	left join dbo.LoginRoleResourceLimits as rl on rl.LoginRoleID = IsNull(@RoleID,0) and rl.ResourceLimitID = l.ResourceLimitID
	left join dbo.LoginResourceLimits as ll on ll.LoginID = IsNull(@LoginID,0) and ll.ResourceLimitID = l.ResourceLimitID
)
GO
