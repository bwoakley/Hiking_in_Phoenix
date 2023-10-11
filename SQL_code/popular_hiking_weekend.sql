-- We compute the aggregate the hiking count monthly, then compute the daily average hiking on weekdays compared to weekends. 

WITH popular_hiking AS (
	SELECT dbo.hiking.Date, dbo.hiking.Site, dbo.hiking.Count,  dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT,
		(CASE
			WHEN (((DATEPART(DW, dbo.hiking.Date) - 1 ) + @@DATEFIRST ) % 7) IN (0,6)
			THEN 1
			ELSE 0
		END) AS is_weekend_day,
		(CASE
			WHEN dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT > 110	THEN 'Why are you hiking?'
			WHEN (dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT < 111 AND dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT > 100 )	THEN 'Too hot'
			WHEN (dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT < 101 AND dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT > 90 )	THEN 'Hot'
			WHEN (dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT < 91 AND dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT > 80 )	THEN 'Warm'
			ELSE 'Ideal'
		END) AS how_hot


	FROM dbo.hiking
	LEFT JOIN dbo.Phoenix_Sky_Harbor_Daily_Temps ON dbo.hiking.Date = dbo.Phoenix_Sky_Harbor_Daily_Temps.Date
	WHERE 
		(dbo.hiking.Site = 'E - PMP - Piestewa Summit Trail' OR
		dbo.hiking.Site = 'E - Camelback - Echo Canyon Trail' OR
		dbo.hiking.Site = 'South Mountain-Pima Dirt Rd.' OR
		dbo.hiking.Site = 'E - Papago - Hole In The Rock' OR
		dbo.hiking.Site = 'N - North Mountain - 44-Tower Road' OR
		dbo.hiking.Site = 'N - Lookout Mountain - 306 - North Side TH' OR
		dbo.hiking.Site = 'South Mountain-Mormon Trail')
		AND dbo.hiking.Count > 10  -- Trims 835 entries, from 10227 to 9392
		AND dbo.hiking.Count < 2500 -- Trims 15 entries, from 9392 to 9377
),

monthly_count_table AS (
	SELECT  MONTH(Date) AS m2, YEAR(DATE) AS y2, is_weekend_day, CONCAT( CAST( MONTH(Date) AS varchar), '/', CAST( YEAR(Date) AS varchar), '_', CAST( is_weekend_day AS varchar) ) AS 'MonthYear_weekend_day_2', SUM(Count) AS monthly_count
	FROM popular_hiking
	GROUP BY is_weekend_day, MONTH(Date), YEAR(DATE)
),

date_weekday AS (
	SELECT Date, MONTH(Date) AS m, YEAR(DATE) AS y, 
		(CASE
			WHEN (((DATEPART(DW, dbo.hiking.Date) - 1 ) + @@DATEFIRST ) % 7) IN (0,6)
			THEN 1
			ELSE 0
		END) AS is_weekend_day
	FROM dbo.hiking
	GROUP BY Date
),

weekdays_per_month AS (
	SELECT m, y, CONCAT( CAST( m AS varchar), '/', CAST( y AS varchar), '_', CAST( is_weekend_day AS varchar) ) AS 'MonthYear_weekend_day', is_weekend_day, COUNT(is_weekend_day) AS num_days_in_month
	FROM date_weekday
	GROUP BY m, y, is_weekend_day
)

SELECT m, y, CONCAT( CAST( m AS varchar), '/', CAST( y AS varchar) ) AS MonthYear, monthly_count_table.is_weekend_day, monthly_count, num_days_in_month, monthly_count/num_days_in_month AS daily_avg
FROM monthly_count_table
LEFT JOIN weekdays_per_month ON monthly_count_table.MonthYear_weekend_day_2 = weekdays_per_month.MonthYear_weekend_day 
ORDER BY y2, m2
