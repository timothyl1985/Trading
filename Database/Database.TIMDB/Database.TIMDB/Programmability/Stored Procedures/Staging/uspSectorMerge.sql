create procedure [Staging].[uspSectorMerge]
as
begin
	set nocount on;
	
	merge into [Reference].[Sector] as target
	using (
		select Name
		from [Staging].[Sector]
		) as source
		on target.Name = source.Name
	when matched then
		update set
			IsEnabled = 1,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user
	when not matched by target then
		insert (Name, IsEnabled, UpdatedDateTime, UpdatedBy, CreatedDateTime, CreatedBy)
		values (source.Name, 1, sysutcdatetime(), system_user, sysutcdatetime(), system_user)
	when not matched by source then
		update set
			IsEnabled = 0,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user;
end