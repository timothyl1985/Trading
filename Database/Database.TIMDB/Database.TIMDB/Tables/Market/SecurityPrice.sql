CREATE TABLE [Market].[SecurityPrice] (
    [Ticker]                [Market].[TickerType],
    [ClosingDate]           DATE            NOT NULL,
    [OpenPrice]             DECIMAL (18, 4) NOT NULL,
    [HighPrice]             DECIMAL (18, 4) NOT NULL,
    [LowPrice]              DECIMAL (18, 4) NOT NULL,
    [ClosePrice]            DECIMAL (18, 4) NOT NULL,
    [Volume]                BIGINT          NOT NULL,
    [RowNumber]             INT             NULL,
    [DayMovement]           DECIMAL (18, 4) NULL,
    [PercentageMovement]    DECIMAL (18, 4) NULL,
	[MA20]					DECIMAL (18, 4) NULL,
    [EMA12]					DECIMAL (18, 4) NULL,
	[EMA26]					DECIMAL (18, 4) NULL,
	[MACD]					DECIMAL (18, 4) NULL,
	[EMA9]					DECIMAL (18, 4) NULL,
    [RSI]					DECIMAL (18, 4) NULL,
    [SOFastK]				DECIMAL (18, 4) NULL,
	[SOFastD]				DECIMAL (18, 4) NULL,
	[UpdatedDateTime]		DATETIME2(3) NOT NULL CONSTRAINT df_SecurityPrice_UpdatedDateTime DEFAULT sysutcdatetime(),
	[UpdatedBy]				varchar(50)  NOT NULL CONSTRAINT df_SecurityPrice_UpdatedBy		  DEFAULT system_user,
	[CreatedDateTime]		DATETIME2(3) NOT NULL CONSTRAINT df_SecurityPrice_CreatedDateTime DEFAULT sysutcdatetime(),
	[Createdby]				varchar(50)  NOT NULL CONSTRAINT df_SecurityPrice_CreatedBy		  DEFAULT system_user,
    CONSTRAINT [pk_SecurityPrice] PRIMARY KEY CLUSTERED ([Ticker] ASC, [ClosingDate] ASC)
) WITH (DATA_COMPRESSION = PAGE);


GO