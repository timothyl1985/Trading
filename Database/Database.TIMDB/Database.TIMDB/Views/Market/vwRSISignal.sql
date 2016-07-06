create view [Market].[vwRSISignal]
as
	with cteNab 
	as
	(
		select SecurityPrice.Ticker, ClosingDate, ClosePrice, RelativeStrengthIndex,
			lag (RelativeStrengthIndex, 1, null) over (partition by SecurityPrice.Ticker order by ClosingDate asc) as PrevRSI
		from Market.SecurityPrice
			inner join Market.ASXCompany
				on SecurityPrice.Ticker = ASXCompany.Ticker
		where ASXCompany.IsEnabled = 1
	)
	, cteTrade as
	(
		select a.Ticker
			, a.ClosingDate as BuyDate, a.ClosePrice as BuyPrice
			, b.ClosingDate as SellDate, b.ClosePrice as SellPrice
			, b.ClosePrice - a.ClosePrice as PriceDiff
			, cast((b.ClosePrice - a.ClosePrice)/a.ClosePrice * 100.00 as decimal(18, 2)) as PercentageChange
			, row_number() over (partition by a.Ticker, a.ClosingDate order by b.ClosingDate asc) as RN
		from cteNab a
			inner join cteNab b
				on a.Ticker = b.Ticker and a.ClosingDate < b.ClosingDate
					and a.RelativeStrengthIndex < 30 and a.PrevRSI >= 30
					and b.RelativeStrengthIndex >= 70 and b.PrevRSI < 70
	)
	select --Ticker, BuyDate, SellDate, BuyPrice, SellPrice, PercentageChange, case when PercentageChange > 0 then 'Profit' else 'Loss' end as PL
		Ticker
			, count(*) as NumTrades
			, cast((sum(case when PercentageChange > 0 then 1 else 0 end) * 100.0)/count(*) as decimal(18, 2)) as ProfitRatio
	from cteTrade
	where RN = 1
	group by Ticker
