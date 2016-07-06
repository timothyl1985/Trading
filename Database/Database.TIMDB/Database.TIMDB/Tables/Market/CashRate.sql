create table [Market].[CashRate]
(
	CashRateID int not null,
	CashRate decimal(18, 2) not null,
	EffectiveStartDate date not null,
	EffectiveEndDate date not null,
	UpdatedDateTime datetime2(3) not null constraint [df_CashRate_UpdatedDateTime] default sysutcdatetime(),
	UpdatedBy varchar(50) not null constraint [df_CashRate_UpdatedBy] default system_user,
	CreatedDatetime datetime2(3) not null constraint [df_CashRate_CreatedDateTime] default sysutcdatetime(),
	CreatedBy varchar(50) not null constraint [df_CashRate_Createdby] default system_user,
	constraint [pk_CashRate] primary key ([CashRateID])
);