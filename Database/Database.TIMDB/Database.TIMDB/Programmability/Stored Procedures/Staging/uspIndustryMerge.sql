create procedure [Staging].[uspIndustryMerge]
as
begin
	set nocount on;
	
	merge into [Reference].[Industry] as target
	using (
		select Sector.SectorID
			, YahooID
			, Industry.Name
		from [Staging].[Industry]
			inner join [Reference].[Sector]
				on Industry.SectorName = Sector.Name
		) as source
		on target.YahooID = source.YahooID
	when matched then
		update set
			SectorID = source.SectorID,
			YahooID = source.YahooID,
			Name = source.Name,
			IsEnabled = 1,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user
	when not matched by target then
		insert (SectorID, YahooID, Name, IsEnabled, UpdatedDateTime, UpdatedBy, CreatedDateTime, CreatedBy)
		values (source.SectorID, source.YahooID, source.Name, 1, sysutcdatetime(), system_user, sysutcdatetime(), system_user)
	when not matched by source then
		update set
			IsEnabled = 0,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user;
end