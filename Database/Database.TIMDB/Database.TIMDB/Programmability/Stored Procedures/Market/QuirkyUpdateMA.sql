create procedure [Market].[QuirkyUpdateMA]
as
begin
	/*************************************************************************************
	 Pseduo-cursor update using the "Quirky Update" to calculate both Running Totals and
	 a Running Count that start over for each AccountID.
	 Takes 24 seconds with the INDEX(0) hint and 6 seconds without it on my box.

	 -- exec [Trade].[QuirkyUpdateMA]
	*************************************************************************************/
	--===== Supress the auto-display of rowcounts for speed an appearance
	set nocount on;

	begin transaction
	--===== Declare the working variables
	declare @PrevTicker [Market].[TickerType], @PrevClosePrice decimal(18, 4), @DummyTotal decimal(18, 4), @DummyTotal2 decimal(18, 4)
		, @RunningTotal12 decimal(18, 4), @RunningTotal26 decimal(18, 4), @RunningTotal20 decimal(18, 4)
		, @PrevEMA12 decimal(18, 4), @PrevEMA26 decimal(18, 4), @Multiplier12 decimal(18, 4), @Multiplier26 decimal(18, 4);

	set @Multiplier12 = 0.1538;
	set @Multiplier26 = 0.074;

	declare @Sum1 decimal(18, 4) = 0, @Sum2 decimal(18, 4) = 0, @Sum3 decimal(18, 4) = 0
		, @Sum4 decimal(18, 4) = 0, @Sum5 decimal(18, 4) = 0, @Sum6 decimal(18, 4) = 0, @Sum7 decimal(18, 4) = 0, @Sum8 decimal(18, 4) = 0
		, @Sum9 decimal(18, 4) = 0, @Sum10 decimal(18, 4) = 0, @Sum11 decimal(18, 4) = 0, @Sum12 decimal(18, 4) = 0, @Sum13 decimal(18, 4) = 0
		, @Sum14 decimal(18, 4) = 0, @Sum15 decimal(18, 4) = 0, @Sum16 decimal(18, 4) = 0, @Sum17 decimal(18, 4) = 0, @Sum18 decimal(18, 4) = 0
		, @Sum19 decimal(18, 4) = 0, @Sum20 decimal(18, 4) = 0, @Sum21 decimal(18, 4) = 0, @Sum22 decimal(18, 4) = 0, @Sum23 decimal(18, 4) = 0
		, @Sum24 decimal(18, 4) = 0, @Sum25 decimal(18, 4) = 0, @Sum26 decimal(18, 4) = 0
		, @rn int = null;

	--===== Update the running total and running count for this row using the "Quirky 
		 -- Update" and a "Pseudo-cursor". The order of the UPDATE is controlled by the
		 -- order of the clustered index.
	 update Market.SecurityPrice
		set @DummyTotal = PercentageMovement = case 
								when Ticker = @PrevTicker then iif(@PrevClosePrice = 0, 0,( ClosePrice * 1.0000 - @PrevClosePrice )/ @PrevClosePrice)
								else 0
								end
			, @DummyTotal2 = DayMovement = case when Ticker = @PrevTicker then ClosePrice - @PrevClosePrice else 0 end
			, @RunningTotal12 = case 
							when Ticker = @PrevTicker
								then @RunningTotal12 + ClosePrice - @Sum12
							else
								ClosePrice
							end	
			, @RunningTotal26 = case 
							when Ticker = @PrevTicker
								then @RunningTotal26 + ClosePrice - @Sum26
							else
								ClosePrice
							end		
			, @RunningTotal20 = case 
							when Ticker = @PrevTicker
								then @RunningTotal20 + ClosePrice - @Sum20
							else
								ClosePrice
							end			
			, @rn = case when Ticker = @PrevTicker then @rn + 1 else 1 end
			, RowNumber = @rn
			, [MA20] = case when @rn >= 20 then @RunningTotal20/20 else null end
			, @PrevEMA12 = [EMA12] = case 
							when Ticker = @PrevTicker then 								
								case when @rn > 12 then ((ClosePrice - @PrevEMA12) * @Multiplier12 + @PrevEMA12)
								else
									case when @rn = 12 
										then @RunningTotal12/12
									else 
										null 
									end
								end
							else 
								null
							end
			, @PrevEMA26 = [EMA26] = case 
							when Ticker = @PrevTicker then 
								case when @rn > 26 then ((ClosePrice - @PrevEMA26) * @Multiplier26 + @PrevEMA26)
								else
									case when @rn = 26 
										then @RunningTotal26/26
									else 
										null 
									end
								end
							else 
								null
							end
			, @Sum26 = case when Ticker = @PrevTicker then @Sum25 else 0 end
			, @Sum25 = case when Ticker = @PrevTicker then @Sum24 else 0 end
			, @Sum24 = case when Ticker = @PrevTicker then @Sum23 else 0 end
			, @Sum23 = case when Ticker = @PrevTicker then @Sum22 else 0 end
			, @Sum22 = case when Ticker = @PrevTicker then @Sum21 else 0 end
			, @Sum21 = case when Ticker = @PrevTicker then @Sum20 else 0 end
			, @Sum20 = case when Ticker = @PrevTicker then @Sum19 else 0 end
			, @Sum19 = case when Ticker = @PrevTicker then @Sum18 else 0 end
			, @Sum18 = case when Ticker = @PrevTicker then @Sum17 else 0 end
			, @Sum17 = case when Ticker = @PrevTicker then @Sum16 else 0 end
			, @Sum16 = case when Ticker = @PrevTicker then @Sum15 else 0 end
			, @Sum15 = case when Ticker = @PrevTicker then @Sum14 else 0 end
			, @Sum14 = case when Ticker = @PrevTicker then @Sum13 else 0 end
			, @Sum13 = case when Ticker = @PrevTicker then @Sum12 else 0 end
			, @Sum12 = case when Ticker = @PrevTicker then @Sum11 else 0 end
			, @Sum11 = case when Ticker = @PrevTicker then @Sum10 else 0 end
			, @Sum10 = case when Ticker = @PrevTicker then @Sum9 else 0 end
			, @Sum9 = case when Ticker = @PrevTicker then @Sum8 else 0 end
			, @Sum8 = case when Ticker = @PrevTicker then @Sum7 else 0 end
			, @Sum7 = case when Ticker = @PrevTicker then @Sum6 else 0 end
			, @Sum6 = case when Ticker = @PrevTicker then @Sum5 else 0 end
			, @Sum5 = case when Ticker = @PrevTicker then @Sum4 else 0 end
			, @Sum4 = case when Ticker = @PrevTicker then @Sum3 else 0 end
			, @Sum3 = case when Ticker = @PrevTicker then @Sum2 else 0 end
			, @Sum2 = case when Ticker = @PrevTicker then @Sum1 else 0 end
			, @Sum1 = ClosePrice
			, @PrevTicker = Ticker
			, @PrevClosePrice = ClosePrice
	   from Market.SecurityPrice with (tablockx)
	 option (maxdop 1);

	update Market.SecurityPrice
	set MACD = EMA12 - EMA26;

	commit transaction;

end