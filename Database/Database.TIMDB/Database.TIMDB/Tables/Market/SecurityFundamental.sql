create table [Market].[SecurityFundamental]
(
	[Ticker]			[Market].[TickerType],
	[EPS]				decimal(18, 4) null,
	[SharesOnIssue]		bigint null,
	[MarketCapBil]		decimal(18, 4) null,
	[DPS]				decimal(18, 4) null,
	[FrankedStatus]		varchar(1) null,
	[NetTangibleAssets]	decimal(18, 4) null,	
	[IsCurrent]			bit not null,
	[EffectiveStartDate]date not null,
	[EffectiveEndDate]	date not null,
	[UpdatedDateTime]	datetime2(3) not null constraint [df_SecurityFundamental_UpdatedDateTime] default sysutcdatetime(),
	[UpdatedBy]			varchar(50) not null constraint [df_SecurityFundamental_UpdatedBy] default system_user,
	[CreatedDateTime]	datetime2(3) NOT NULL CONSTRAINT [df_SecurityYahoo_CreatedDateTime]  DEFAULT (sysutcdatetime()),
	[CreatedBy]			varchar(50) NOT NULL CONSTRAINT [df_SecurityYahoo_CreatedBy]  DEFAULT (suser_sname())
);