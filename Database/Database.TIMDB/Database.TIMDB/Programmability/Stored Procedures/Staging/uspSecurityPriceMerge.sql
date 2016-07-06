create procedure [Staging].[uspSecurityPriceMerge]
as
begin
	set nocount on;
	
	merge into Market.SecurityPrice as target
	using Staging.SecurityPrice as source
		on target.Ticker = source.Ticker and target.ClosingDate = source.ClosingDate
	when not matched by target then
		insert ([Ticker], [ClosingDate], [OpenPrice], [HighPrice], [LowPrice], [ClosePrice], [Volume])
		values ([Ticker], [ClosingDate], [OpenPrice], [HighPrice], [LowPrice], [ClosePrice], [Volume])
	when matched and exists (
		select source.Ticker, source.ClosingDate, source.OpenPrice, source.HighPrice, source.LowPrice, source.ClosePrice, source.Volume
		except
		select target.Ticker, target.ClosingDate, target.OpenPrice, target.HighPrice, target.LowPrice, target.ClosePrice, target.Volume
		) then update
		set Ticker = source.Ticker,
			ClosingDate = source.ClosingDate,
			OpenPrice = source.OpenPrice,
			HighPrice = source.HighPrice,
			LowPrice = source.LowPrice,
			ClosePrice = source.ClosePrice,
			Volume = source.Volume,
			UpdatedDateTime = sysutcdatetime(),
			UpdatedBy = system_user;

end