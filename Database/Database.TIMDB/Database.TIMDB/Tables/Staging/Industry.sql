create table [Staging].[Industry]
(
	[SectorName] varchar(250) not null,
	[YahooID] int not null,
	[Name] varchar(250) not null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null
)
