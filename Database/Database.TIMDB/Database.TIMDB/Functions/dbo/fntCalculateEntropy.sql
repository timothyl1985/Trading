CREATE function dbo.fnCalculateEntropy (@value1 decimal(18,4), @value2 decimal(18,4), @total decimal(18,4))
returns decimal(18,2)
as
begin
	declare @returnValue as decimal(18,4)
	declare @result1 as decimal(18,4)
	declare @result2 as decimal(18,4)
	declare @resultTotal as decimal(18,4)
	
	set @resultTotal = @value1 + @value2
	set @result1 = @value1/@resultTotal
	set @result2 = @value2/@resultTotal

	select @returnValue = (@result1 *log(@result1, 2) + @result2*log(@result2, 2)) * -1 * @resultTotal/@total * 1.00

	return @returnValue
end
