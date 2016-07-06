CREATE TABLE [Util].[DimDate] (
	[DimDateID] int not null,
    [DateKey]   date not null,
    [DayOfWeek] int not null,
	[IsWeekDay] bit not null,
	[UpdatedDateTime] datetime2(3) not null constraint [df_DimDate_UpdatedDateTime] default sysutcdatetime(),
	[Updatedby] varchar(50) not null constraint [df_DimDate_UpdatedBy] default system_user,
	[CreatedDateTime] datetime2(3) not null constraint [df_DimDate_CreatedDateTime] default sysutcdatetime(),
	[Createdby] varchar(50) not null constraint [df_DimDate_CreatedBy] default system_user,
	constraint [pk_DimDate] primary key ([DimDateID])
);

