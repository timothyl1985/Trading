CREATE SERVICE [enterTrade]
    AUTHORIZATION [dbo]
    ON QUEUE [dbo].[tradeAckQueue]
    ([//www.develop.com/DMBrokerage/EnterTrade]);

