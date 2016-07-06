create table [Staging].[SecurityFundamental]
(
	[Ticker]			[Market].[TickerType],
	[CompanyName]		varchar(250) null,
	[TradeDate]			date not null,
	[EPS]				decimal(18, 4) null,
	[PE]				decimal(18, 4) null,
	[MarketCapBil]		decimal(18, 4) null,
	[SharesOnIssue]		bigint null,
	[DPS]				decimal(18, 4) null,
	[DivYield]			decimal(18, 4) null,
	[FrankedStatus]		varchar(1) null,
	[NetTangibleAssets]	decimal(18, 4) null,	
	[SourceID]			int			   null,
	[CreatedDateTime]	datetime2(3) not null constraint [df_SecurityFundamental_CreatedDateTime]  default (sysutcdatetime()),
	[CreatedBy]			varchar(50) not null constraint [df_SecurityFundamental_CreatedBy]  default (suser_sname())
);
