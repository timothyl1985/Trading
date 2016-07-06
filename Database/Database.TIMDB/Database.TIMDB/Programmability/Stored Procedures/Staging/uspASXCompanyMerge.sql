create procedure [Staging].[uspASXCompanyMerge]
as
begin
	set nocount on;
	
	merge into [Market].[ASXCompany] as target
	using (
		select [Ticker],
			[CompanyName],
			[GICSIndustryGroupName]
		from [Staging].[ASXCompany]
		) as source
		on target.Ticker = source.Ticker
	when matched 
		and (exists (select target.Name except select source.CompanyName) or target.IsEnabled = 0)
		then
		update set
			IsEnabled = 1,
			Name = source.CompanyName,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user
	when not matched by target then
		insert (Ticker, Name, IsEnabled, UpdatedDateTime, UpdatedBy, CreatedDateTime, CreatedBy)
		values (source.Ticker, source.CompanyName, 1, sysutcdatetime(), system_user, sysutcdatetime(), system_user)
	when not matched by source then
		update set
			IsEnabled = 0,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user;
end