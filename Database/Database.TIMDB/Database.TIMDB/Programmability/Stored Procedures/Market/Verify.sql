CREATE PROCEDURE [Market].[Verify] AS
/*************************************************************************************
 Code to verify that the account running total calculation worked correctly.
 Please read the comments to see how it works.
*************************************************************************************/
--===== Conditionally drop the verification table to make
     -- it easy to rerun the verification code
     IF OBJECT_ID('TempDB..#Verification') IS NOT NULL
   DROP TABLE dbo.#Verification

--===== Define a variable to remember the number of rows
     -- copied to the verification table
DECLARE @MyCount INT

--===== Copy the data from the test table into the
     -- verification table in the correct order.
     -- Remember the correct order with an IDENTITY.
 SELECT IDENTITY(INT,1,1) AS RowNum,
		Ticker,
		OpenPrice,
		ClosePrice,
		DayMovement,
        PercentageMovement
   INTO #Verification
   FROM Market.SecurityPrice
  ORDER BY Ticker, ClosingDate

--===== Remember the number of rows we just copied
 SELECT @MyCount = @@ROWCOUNT

--===== 1. Check the Day Movement calculations by calculating difference from previous Close Price
 SELECT CASE 
			WHEN COUNT(hi.RowNum) + 1 = @MyCount
			THEN 'Day Movement Calculations are correct'
			ELSE 'There are some errors in the Day Movement Calculations'
        END
   FROM #Verification lo
  INNER JOIN
        #Verification hi
     ON lo.RowNum + 1 = hi.RowNum
  WHERE (-- Compare lines with the same Ticker
         hi.Ticker = lo.Ticker
         and hi.ClosePrice = lo.ClosePrice + hi.DayMovement)
     or
        (-- First line of Ticker has Day Movement as 0
         hi.Ticker <> lo.Ticker
			and hi.DayMovement = 0)


--===== 2. Check the Percentage Movement calculations
 SELECT CASE 
            WHEN COUNT(hi.RowNum) + 1 = @MyCount
            THEN 'Percentage Movement Calculations are correct'
            ELSE 'There are some errors in the Percentage Movement Totals'
        END
   FROM #Verification lo
  INNER JOIN
        #Verification hi
     ON lo.RowNum + 1 = hi.RowNum
  WHERE (-- Compare lines with the same Ticker
         hi.Ticker = lo.Ticker
         and hi.PercentageMovement = cast(iif(lo.ClosePrice = 0, 0,( hi.ClosePrice * 1.0000 - lo.ClosePrice )/ lo.ClosePrice) as decimal(18, 4)))
     or
        (-- First line of Ticker has Percentage Movement as 0
         hi.Ticker <> lo.Ticker
			and hi.PercentageMovement = 0)

--===== 3. Check the 20 Day Moving Average calculations
;with MovingAverageCheck_cte
as (
	select Ticker, ClosePrice, [MA20]
		, cast(avg(ClosePrice) over (partition by Ticker order by ClosingDate asc rows between 19 preceding and current row) as decimal(18, 4))
			as [Expected20DayMovingAverage]
	from Market.SecurityPrice
)
select CASE 
            WHEN count(*) > 0
            THEN 'There are some errors in the 20 Day Moving Average calculations'
            ELSE '20 Day Moving Average Calculations are correct.'
        END
from MovingAverageCheck_cte
where [MA20] <> [Expected20DayMovingAverage]