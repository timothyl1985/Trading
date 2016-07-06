CREATE function Util.fntSplitString 
(
	@StringToSplit varchar(max),
	@Delimiter char(1)
)
returns table
as return
(
	select row_number() over (order by (select null)) as ID, substring(@StringToSplit, ID, charindex(@Delimiter, @StringToSplit, ID) - ID) as Token
	from Util.Numbers
	where ID < len(@StringToSplit)
		and substring(@StringToSplit, ID - 1 , 1) = @Delimiter
)