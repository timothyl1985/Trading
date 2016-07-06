create table [Market].[ASXCompany]
(
	[ASXCompanyID] int identity(1, 1) not null,
	[Name] varchar(250) not null,
	[Ticker] [Market].[TickerType],
	[IsEnabled] bit not null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null,
	[UpdatedDateTime] datetime2(3) not null,
	[UpdatedBy] varchar(100) not null
	constraint pk_ASXCompany primary key ([ASXCompanyID])
);
go
create unique nonclustered index uq_ASXCompany_Ticker
	on [Market].[ASXCompany] ([ASXCompanyID]);
go
