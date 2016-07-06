create table [Staging].[Company]
(
	[YahooIndustryID] int not null,
	[IndustryName] varchar(250) not null,
	[Name] varchar(250) not null,
	[Symbol] varchar(50) not null,
	[Ticker] varchar(20) null,
	[Exchange] varchar(10) null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null
);