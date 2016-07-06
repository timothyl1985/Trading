create table [Reference].[Sector]
(
	[SectorID] int identity(1, 1) not null,
	[Name] varchar(250) not null,
	[IsEnabled] bit not null,
	[UpdatedDateTime] datetime2(3) not null,
	[UpdatedBy] varchar(100) not null,
	[CreatedDateTime] datetime2(3) not null,
	[CreatedBy] varchar(100) not null,
	constraint pk_Sector primary key ([SectorID])
);
go
create unique nonclustered index uq_Sector_Name on
	[Reference].[Sector]([Name]);
go