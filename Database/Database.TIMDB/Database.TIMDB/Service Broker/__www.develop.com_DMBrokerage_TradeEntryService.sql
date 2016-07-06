CREATE SERVICE [//www.develop.com/DMBrokerage/TradeEntryService]
    AUTHORIZATION [dbo]
    ON QUEUE [dbo].[tradeEntryQueue]
    ([//www.develop.com/DMBrokerage/EnterTrade]);

