CREATE QUEUE [dbo].[tradeAckQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[tradeAckProc], MAX_QUEUE_READERS = 5, EXECUTE AS N'dbo');

