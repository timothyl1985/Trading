CREATE MESSAGE TYPE [//www.develop.com/DMBrokerage/TradeEntry]
    AUTHORIZATION [dbo]
    VALIDATION = VALID_XML WITH SCHEMA COLLECTION [dbo].[TradeEntrySchema];

