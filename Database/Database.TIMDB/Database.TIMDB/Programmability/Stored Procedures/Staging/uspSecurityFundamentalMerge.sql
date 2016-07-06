create procedure [Staging].[uspSecurityFundamentalMerge]
as
begin
	set nocount on;

	create table #SecurityFundamental
	(
		[Ticker]			varchar(10) not null,
		[TradeDate]			date not null,
		[EPS]				decimal(18, 4) null,
		[MarketCapBil]		decimal(18, 4) null,
		[SharesOnIssue]		bigint null,
		[DPS]				decimal(18, 4) null,
		[FrankedStatus]		varchar(1) null,
		[NetTangibleAssets]	decimal(18, 4) null,	
		[SourceID]			int			   null,
	);

	update Staging.SecurityFundamental
	set SharesOnIssue = cast(MarketCapBil * 1000000000 / ClosePrice as bigint)
	from Staging.SecurityFundamental
		left join Market.SecurityPrice
			on SecurityFundamental.Ticker = SecurityPrice.Ticker and SecurityFundamental.TradeDate = SecurityPrice.ClosingDate

	;with cteStagingFundamental as 
	(
		select Ticker, TradeDate, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, SourceID 
			, RN = row_number() over (partition by Ticker order by SourceID asc)
		from Staging.SecurityFundamental
		where CompanyName not like '  %'
	)
	insert into #SecurityFundamental
	select Ticker, TradeDate, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, SourceID 
	from cteStagingFundamental
	where RN = 1

	-- 1. Expire previous and insert latest dimension
	-- 2. Insert new dimension
	insert into Market.SecurityFundamental (Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, IsCurrent, EffectiveStartDate, EffectiveEndDate)
	select Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, 1, dateadd(dd, 1, EffectiveEndDate), '99991231'
	from (
		merge into Market.SecurityFundamental as target
		using #SecurityFundamental as source
			on target.Ticker = source.Ticker
		when matched and source.TradeDate > target.EffectiveStartDate and target.IsCurrent = 1 and ( exists
			(select target.EPS, target.DPS, target.FrankedStatus, target.NetTangibleAssets
			except 
			select source.EPS, source.DPS, source.FrankedStatus, source.NetTangibleAssets) 
				or abs((target.SharesOnIssue - source.SharesOnIssue)/target.SharesOnIssue) >= 0.001
				or (target.SharesOnIssue is null and source.SharesOnIssue is not null)
			) then
			update set
				target.IsCurrent = 0,
				target.EffectiveEndDate = dateadd(dd, -1, source.TradeDate),
				target.UpdatedDateTime = sysutcdatetime(),
				target.UpdatedBy = system_user
		when not matched by target then
			insert (Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, IsCurrent, EffectiveStartDate, EffectiveEndDate)
			values (source.Ticker, source.EPS, source.MarketCapBil, source.SharesOnIssue, source.DPS, source.FrankedStatus, source.NetTangibleAssets
				, 1 , source.TradeDate, '99991231')
		output $action, Inserted.Ticker, source.EPS, source.MarketCapBil, source.SharesOnIssue, source.DPS, source.FrankedStatus
			, source.NetTangibleAssets, Inserted.EffectiveEndDate
		) sec (Action, Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, EffectiveEndDate)
	where Action = 'UPDATE';

	-- 3. Update previous dimension changes
	merge into Market.SecurityFundamental as target
	using #SecurityFundamental as source
		on target.Ticker = source.Ticker
	when matched and source.TradeDate = target.EffectiveStartDate and ( exists
		(select target.EPS, target.DPS, target.FrankedStatus, target.NetTangibleAssets
		except 
		select source.EPS, source.DPS, source.FrankedStatus, source.NetTangibleAssets) 
			or abs((target.SharesOnIssue - source.SharesOnIssue)/target.SharesOnIssue) >= 0.001
			or (target.SharesOnIssue is null and source.SharesOnIssue is not null)
		) then
		update set
			target.EPS = source.EPS,
			target.MarketCapBil = source.MarketCapBil,
			target.SharesOnIssue = source.SharesOnIssue,
			target.DPS = source.DPS,
			target.FrankedStatus = source.FrankedStatus,
			target.NetTangibleAssets = source.NetTangibleAssets,
			target.UpdatedDateTime = sysutcdatetime(),
			target.UpdatedBy = system_user;

	-- 4. Back-date dimension changes
	create table #BackDateSF (Ticker varchar(10) not null primary key
		, PrevEffectiveStartDate date not null, NewPrevEffectiveEndDate date not null, NewEffectiveStartDate date not null, NewEffectiveEndDate date not null
		, EPS decimal(18, 4) null, MarketCapBil decimal(18, 4), SharesOnIssue bigint null
		, DPS decimal(18, 4) null, FrankedStatus varchar(1) null, NetTangibleAssets decimal(18, 4) null);

	insert into #BackDateSF
	select SF.Ticker, PrevEffectiveStartDate, NewPrevEffectiveEndDate, NewEffectiveStartDate, NewEffectiveEndDate
		, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets
	from (
		select msf.Ticker as SFTicker, msf.EffectiveStartDate as PrevEffectiveStartDate
			, dateadd(dd, -1, sf.TradeDate) as NewPrevEffectiveEndDate
			, sf.TradeDate as NewEffectiveStartDate
			, dateadd(dd, -1, lead(msf.EffectiveStartDate, 1) over (partition by msf.Ticker order by msf.EffectiveStartDate)) as NewEffectiveEndDate
			, sf.*
		from Market.SecurityFundamental msf
			left join #SecurityFundamental sf 
				on msf.Ticker  = sf.Ticker
					and sf.TradeDate > msf.EffectiveStartDate and sf.TradeDate < msf.EffectiveEndDate and msf.IsCurrent = 0
					and (sf.EPS <> msf.EPS or sf.EPS <> msf.EPS or abs((msf.SharesOnIssue - sf.SharesOnIssue)/msf.SharesOnIssue) >= 0.001 or sf.DPS <> msf.DPS or sf.FrankedStatus <> msf.FrankedStatus
						or sf.NetTangibleAssets <> msf.NetTangibleAssets)
		) SF
	where SF.Ticker is not null

	update Market.SecurityFundamental
	set EffectiveEndDate = #BackDateSF.NewPrevEffectiveEndDate
		, UpdatedDateTime = sysutcdatetime()
		, UpdatedBy = system_user
	from #BackDateSF
		inner join Market.SecurityFundamental
			on #BackDateSF.Ticker = SecurityFundamental.Ticker and #BackDateSF.PrevEffectiveStartDate = SecurityFundamental.EffectiveStartDate;

	insert into Market.SecurityFundamental (Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus
		, NetTangibleAssets, IsCurrent, EffectiveStartDate, EffectiveEndDate)
	select Ticker, EPS, MarketCapBil, SharesOnIssue, DPS, FrankedStatus, NetTangibleAssets, 0, NewEffectiveStartDate, NewEffectiveEndDate
	from #BackDateSF;
end
