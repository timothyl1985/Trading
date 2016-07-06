create procedure [Market].[QuirkyUpdateEMA]
as
begin
	/*************************************************************************************
	 Pseduo-cursor update using the "Quirky Update" to calculate both Running Totals and
	 a Running Count that start over for each AccountID.
	 Takes 24 seconds with the INDEX(0) hint and 6 seconds without it on my box.

	 -- exec [Trade].[QuirkyUpdateEMA]
	*************************************************************************************/
	--===== Supress the auto-display of rowcounts for speed an appearance
	set nocount on;

	begin transaction
	--===== Declare the working variables
	declare @PrevTicker [Market].[TickerType], @RunningTotal decimal(18, 4), @PrevEMA decimal(18, 4), @Multiplier decimal(18, 4);

	set @Multiplier = 0.2;

	declare @Sum1 decimal(18, 4) = 0, @Sum2 decimal(18, 4) = 0, @Sum3 decimal(18, 4) = 0
		, @Sum4 decimal(18, 4) = 0, @Sum5 decimal(18, 4) = 0, @Sum6 decimal(18, 4) = 0, @Sum7 decimal(18, 4) = 0, @Sum8 decimal(18, 4) = 0
		, @Sum9 decimal(18, 4) = 0, @rn int = null;

	--===== Update the running total and running count for this row using the "Quirky 
		 -- Update" and a "Pseudo-cursor". The order of the UPDATE is controlled by the
		 -- order of the clustered index.
	 update Market.SecurityPrice
		set @RunningTotal = case when @rn >= 25  then
								case when Ticker = @PrevTicker then
									 @RunningTotal + MACD - isnull(@Sum9, 0)
								else
									MACD
								end
							else
								0
							end	
			, @rn = case when Ticker = @PrevTicker then @rn + 1 else 1 end
			, RowNumber = @rn
			, @PrevEMA = [EMA9] = case 
							when Ticker = @PrevTicker then 								
								case when @rn > 34 then ((MACD - @PrevEMA) * @Multiplier + @PrevEMA)
								else
									case when @rn = 34 
										then @RunningTotal/9
									else 
										null 
									end
								end
							else 
								null
							end
			, @Sum9 = case when Ticker = @PrevTicker then @Sum8 else 0 end
			, @Sum8 = case when Ticker = @PrevTicker then @Sum7 else 0 end
			, @Sum7 = case when Ticker = @PrevTicker then @Sum6 else 0 end
			, @Sum6 = case when Ticker = @PrevTicker then @Sum5 else 0 end
			, @Sum5 = case when Ticker = @PrevTicker then @Sum4 else 0 end
			, @Sum4 = case when Ticker = @PrevTicker then @Sum3 else 0 end
			, @Sum3 = case when Ticker = @PrevTicker then @Sum2 else 0 end
			, @Sum2 = case when Ticker = @PrevTicker then @Sum1 else 0 end
			, @Sum1 = MACD
			, @PrevTicker = Ticker
	   from Market.SecurityPrice with (tablockx)
	 option (maxdop 1);
	 
	commit transaction;

end