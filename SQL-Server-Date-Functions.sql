/******************************
** Name: SQL Dates
** Desc: A compilation of various date functions for SQL Server
** Auth: Bonza Owl
** Date: 28/11/2018
*******************************/

--FirstDayOfCurrentWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0)) AS [FirstDayOfCurrentWeek]
--LastDayOfCurrentWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 6)) AS [LastDayOfCurrentWeek]
--FirstDayOfLastWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 7, GETDATE()), 0)) AS [FirstDayOfPeviousWeek]
--LastDayOfLastWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 7, GETDATE()), 6)) AS [LastDayOfPreviousWeek]
--FirstDayOfNextWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 7)) AS [FirstDayOfNextWeek]
--LastDayOfNextWeek 
SELECT CONVERT(DATE, DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 13)) AS [LastDayOfNextWeek]
--FirstDayOfCurrentMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(GETDATE() - 1) ), GETDATE())) AS [FirstDayOfCurrentMonth]
--LastDayOfCurrentMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, 1, GETDATE())) ), DATEADD(m, 1, GETDATE()))) AS [LastDayOfCurrentMonth]
--FirstDayOfLastMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, GETDATE() - 2)) ), DATEADD(m, -1, GETDATE() - 1))) AS [FirstDayOfPreviousMonth]
--LastDayOfLastMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(GETDATE()) ), GETDATE())) AS [LastDayOfPreviousMonth]
--FirstDayOfNextMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, 1, GETDATE() - 1)) ), DATEADD(m, 1, GETDATE()))) AS [FirstDayOfNextMonth]
--LastDayOfNextMonth 
SELECT CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, 2, GETDATE())) ), DATEADD(m, 2, GETDATE()))) AS [LastDayOfNextMonth]
--FirstDayOfCurrentYear 
SELECT CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)) AS [FirstDayOfCurrentYear]
--LastDayOfCurrentYear 
SELECT CONVERT(DATE, DATEADD(ms, -2, DATEADD(YEAR, 0, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, 0)))) AS [LastDayOfCurrentYear]
--FirstDayOfLastYear
 SELECT CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) - 1, 0)) AS [FistDayOfLastYear]
--LastDayOfLastYear 
SELECT CONVERT(DATE, DATEADD(ms, -2, DATEADD(YEAR, 0, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)))) AS [LastDayOfPreviousYear]
--FirstDayOfNextYear 
SELECT CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, 0)) AS [FirstDayOfPreviousYear]
--LastDayOfNextYear 
SELECT CONVERT(DATE, DATEADD(ms, -2, DATEADD(YEAR, 0, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 2, 0)))) AS [LastDayOfNextYear]
--CurrentYear
SELECT DATEPART(year,GETDATE()) AS [CurrentYear]
--CurrentMonth
SELECT DATEPART(month,GETDATE()) AS [CurrentMonth]
--CurrentWeekNumber
SELECT DATEPART(wk,GETDATE()) AS [CurrentWeekNumber]
--CurrentDayInMonth
SELECT DATEPART(day,GETDATE()) CurrentDay
--GetWeekDayName
SELECT DATENAME(weekday,GETDATE()) AS WeekdayName
--GetWeekDay
SELECT DATEPART(weekday,GETDATE()) AS WeekdayNumber
--Date30DaysAgo
SELECT DATEADD(day,-30,GETDATE()) AS Date30DaysAgo
--Date30DaysFuture
SELECT DATEADD(day,+30, GETDATE()) AS Date30DaysFuture
