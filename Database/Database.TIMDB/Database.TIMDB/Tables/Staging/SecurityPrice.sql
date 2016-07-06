CREATE TABLE [Staging].[SecurityPrice](
	[Ticker] [Market].[TickerType],
	[ClosingDate] [date] NOT NULL,
	[OpenPrice] [decimal](18, 4) NOT NULL,
	[HighPrice] [decimal](18, 4) NOT NULL,
	[LowPrice] [decimal](18, 4) NOT NULL,
	[ClosePrice] [decimal](18, 4) NOT NULL,
	[Volume] [bigint] NOT NULL,
	[AdjustedClose] [decimal](18, 6) NULL,
	[CreatedDateTime] [datetime] NOT NULL constraint df_SecurityPrice_CreatedDateTime default sysutcdatetime(),
	[CreatedBy] [varchar](50) NOT NULL constraint df_SecurityPrice_CreatedBy default system_user,
);