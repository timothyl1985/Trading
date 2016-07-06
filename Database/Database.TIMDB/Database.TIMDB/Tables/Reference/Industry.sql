create table [Reference].[Industry]
(
	[IndustryID] int identity(1, 1) not null,
	[SectorID] int not null,
	[YahooID] int not null,
	[Name] varchar(250) not null,
	[IsEnabled] bit not null,
	[UpdatedDateTime] datetime2(3) not null,
	[UpdatedBy] varchar(100) not null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null,
	constraint pk_Industry primary key ([IndustryID]),
	constraint fk_Industry_Sector_SectorID foreign key ([SectorID]) references [Reference].[Sector]([SectorID])
);
go
create unique nonclustered index uq_Industry_YahooID
	on [Reference].[Industry]([YahooID]);
go
