create table [Staging].[SecurityYahoo]
(
	[Ticker]			[Market].[TickerType],
	[TradeDate]			date NULL,
	[EPS]				decimal(18, 4) NULL,
	[PE]				decimal(18, 4) NULL,
	[FloatShares]		int NULL,
	[MarketCap]			decimal(18, 4) NULL,
	[CreatedDateTime]	datetime2(3) NOT NULL CONSTRAINT [df_SecurityYahoo_CreatedDateTime]  DEFAULT (sysutcdatetime()),
	[CreatedBy]			varchar(50) NOT NULL CONSTRAINT [df_SecurityYahoo_CreatedBy]  DEFAULT (suser_sname())
);