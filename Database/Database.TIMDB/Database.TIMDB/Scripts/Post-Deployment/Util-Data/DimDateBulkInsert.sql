if object_id(N'tempdb..#DimDate') is not null
	drop table #DimDate;
go
create table #DimDate
(
	DimDateID int not null,
	DateKey date not null,
	DayOfWeek int not null,
	IsWeekDay bit not null
);

declare @FirstDate date = '20000101';
with ctea as ( select 1 as a union all select 1 union all select 1 union all select 1)
, cteb as (select 1 as a from ctea a cross join ctea b)
, ctec as (select 1 as a from cteb a cross join cteb b)
, cted as (select 1 as a from ctec a cross join ctec b)
, ctee as ( select row_number() over (order by (select null)) - 1 as RN from cted)
insert into #DimDate (DimDateID, DateKey, DayOfWeek, IsWeekDay)
select cast(convert(varchar(50), dateadd(dd, RN, @FirstDate), 112) as int) as DimDateID
	, dateadd(dd, RN, @FirstDate) as DateKey
	, datepart(dw, dateadd(dd, RN, @FirstDate)) as DayOfWeek
	, case when datepart(dw, dateadd(dd, RN, @FirstDate)) <= 5 then 1 else 0 end IsWeekDay
from ctee

merge into Util.DimDate as target
using #DimDate as source
	on target.DimDateID = source.DimDateID
when matched then
	update set 
		target.DateKey = source.DateKey,
		target.DayOfWeek = source.DayOfWeek,
		target.IsWeekDay = source.IsWeekDay,
		target.UpdatedDateTime = sysutcdatetime(),
		target.UpdatedBy = system_user
when not matched by target then
	insert (DimDateID, DateKey, DayOfWeek, IsWeekDay)
	values (source.DimDateID, source.DateKey, source.DayOfWeek, source.IsWeekDay)
when not matched by source then
	delete;
