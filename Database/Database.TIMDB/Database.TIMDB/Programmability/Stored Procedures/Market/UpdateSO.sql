create procedure [Market].[UpdateSO]
as
begin
	set nocount on;

	with SO_cte as
	(
		select Ticker, ClosingDate, ClosePrice, SOFastK, SOFastD
			, min(LowPrice) over (partition by Ticker order by ClosingDate asc rows between 13 preceding and current row) as LowPrice
			, max(HighPrice) over (partition by Ticker order by ClosingDate asc rows between 13 preceding and current row) as HighPrice
			, row_number() over (partition by Ticker order by ClosingDate asc) as RN
		from [Market].[SecurityPrice]
	), SO_FastK_Cte as
	(
		select *
			, SOFastKValue = case when HighPrice = LowPrice
					then 
						case when ClosePrice > HighPrice then 100 else 0 end
					else 
						100 * (ClosePrice - LowPrice)/(HighPrice - LowPrice) end
		from SO_cte
		where RN >= 14
	), SO_FastD_Cte as
	(
		select *
			, SOFastDValue = case when RN >= 16 then avg(SOFastKValue) over (partition by Ticker order by ClosingDate asc rows between 2 preceding and current row) else null end
		from SO_FastK_Cte
	)

	update SO_FastD_Cte
	set SOFastK = SOFastKValue
		, SOFastD = SOFastDValue

end