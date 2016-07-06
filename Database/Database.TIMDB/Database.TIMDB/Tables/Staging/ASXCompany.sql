create table [Staging].[ASXCompany]
(
	[Ticker] [Market].[TickerType],
	[CompanyName] varchar(250) not null,
	[GICSIndustryGroupName] varchar(250) not null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null
);
