CREATE procedure [Market].[QuirkyUpdateRSI]
as
begin
	set nocount on;

	begin transaction
		--===== Declare the working variables
		declare @PrevTicker [Market].[TickerType]
		declare @PrevDayMovement decimal(18, 4)
		declare @DummyVariable decimal(18, 4)
	
		declare @DayMovement1 decimal(18, 4) = 0, @DayMovement2 decimal(18, 4) = 0, @DayMovement3 decimal(18, 4) = 0
			, @DayMovement4 decimal(18, 4) = 0, @DayMovement5 decimal(18, 4) = 0, @DayMovement6 decimal(18, 4) = 0, @DayMovement7 decimal(18, 4) = 0, @DayMovement8 decimal(18, 4) = 0
			, @DayMovement9 decimal(18, 4) = 0, @DayMovement10 decimal(18, 4) = 0, @DayMovement11 decimal(18, 4) = 0, @DayMovement12 decimal(18, 4) = 0, @DayMovement13 decimal(18, 4) = 0
			, @DayMovement14 decimal(18, 4) = 0, @rn int = null;

		declare @MAUpDays decimal(18, 4), @MADownDays decimal(18, 4), @RS decimal(18, 4);

		--===== Update the running total and running count for this row using the "Quirky 
			-- Update" and a "Pseudo-cursor". The order of the UPDATE is controlled by the
			-- order of the clustered index.
		update Market.SecurityPrice
		set   @rn = case when Ticker = @PrevTicker then @rn + 1 else 1 end
			, RSI = case when @rn < 14
				then 
					null 
				else
					100 - case when @MADownDays = 0 then 0 else 100 / (1 + @MAUpDays/@MADownDays) end 
				end
			, @MAUpDays = ((case when DayMovement > 0 then DayMovement else 0 end ) +
				(case when @DayMovement1 > 0 then @DayMovement1 else 0 end ) + (case when @DayMovement2 > 0 then @DayMovement2 else 0 end ) +
				(case when @DayMovement3 > 0 then @DayMovement3 else 0 end ) + (case when @DayMovement4 > 0 then @DayMovement4 else 0 end ) +
				(case when @DayMovement5 > 0 then @DayMovement5 else 0 end ) + (case when @DayMovement6 > 0 then @DayMovement6 else 0 end ) +
				(case when @DayMovement7 > 0 then @DayMovement7 else 0 end ) + (case when @DayMovement8 > 0 then @DayMovement8 else 0 end ) +
				(case when @DayMovement9 > 0 then @DayMovement9 else 0 end ) + (case when @DayMovement10 > 0 then @DayMovement10 else 0 end ) +
				(case when @DayMovement11 > 0 then @DayMovement11 else 0 end ) + (case when @DayMovement12 > 0 then @DayMovement12 else 0 end ) +
				(case when @DayMovement13 > 0 then @DayMovement13 else 0 end ))/(case when @rn < 14 then @rn else 14 end)
			, @MADownDays = abs((case when DayMovement < 0 then DayMovement else 0 end ) +
				(case when @DayMovement1 < 0 then @DayMovement1 else 0 end ) + (case when @DayMovement2 < 0 then @DayMovement2 else 0 end ) +
				(case when @DayMovement3 < 0 then @DayMovement3 else 0 end ) + (case when @DayMovement4 < 0 then @DayMovement4 else 0 end ) +
				(case when @DayMovement5 < 0 then @DayMovement5 else 0 end ) + (case when @DayMovement6 < 0 then @DayMovement6 else 0 end ) +
				(case when @DayMovement7 < 0 then @DayMovement7 else 0 end ) + (case when @DayMovement8 < 0 then @DayMovement8 else 0 end ) +
				(case when @DayMovement9 < 0 then @DayMovement9 else 0 end ) + (case when @DayMovement10 < 0 then @DayMovement10 else 0 end ) +
				(case when @DayMovement11 < 0 then @DayMovement11 else 0 end ) + (case when @DayMovement12 < 0 then @DayMovement12 else 0 end ) +
				(case when @DayMovement13 < 0 then @DayMovement13 else 0 end ))/(case when @rn < 15 then @rn else 14 end)
			, @DayMovement14 = case when Ticker = @PrevTicker then @DayMovement13 else 0 end
			, @DayMovement13 = case when Ticker = @PrevTicker then @DayMovement12 else 0 end
			, @DayMovement12 = case when Ticker = @PrevTicker then @DayMovement11 else 0 end
			, @DayMovement11 = case when Ticker = @PrevTicker then @DayMovement10 else 0 end
			, @DayMovement10 = case when Ticker = @PrevTicker then @DayMovement9 else 0 end
			, @DayMovement9 = case when Ticker = @PrevTicker then @DayMovement8 else 0 end
			, @DayMovement8 = case when Ticker = @PrevTicker then @DayMovement7 else 0 end
			, @DayMovement7 = case when Ticker = @PrevTicker then @DayMovement6 else 0 end
			, @DayMovement6 = case when Ticker = @PrevTicker then @DayMovement5 else 0 end
			, @DayMovement5 = case when Ticker = @PrevTicker then @DayMovement4 else 0 end
			, @DayMovement4 = case when Ticker = @PrevTicker then @DayMovement3 else 0 end
			, @DayMovement3 = case when Ticker = @PrevTicker then @DayMovement2 else 0 end
			, @DayMovement2 = case when Ticker = @PrevTicker then @DayMovement1 else 0 end
			, @DayMovement1 = DayMovement
			, @PrevTicker = Ticker
		from Market.SecurityPrice with (tablockx)
		option (maxdop 1)

	commit transaction;
end