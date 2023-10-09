-- Join with the daily max temp
-- Also clean by dropping rows where count < 10

WITH clean_records AS (
	SELECT *
	FROM dbo.hiking
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

agg_counts AS (
	SELECT SUM(Count) AS 'monthly_count', Site, 
	CONCAT( CAST( MONTH(Date) AS varchar), '/', CAST( YEAR(Date) AS varchar) ) AS 'MonthYear_Count'
	FROM clean_records
	GROUP BY YEAR(Date), MONTH(Date), Site
),

monthly_temp AS (
	SELECT AVG(dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT) AS 'Monthly_avg_high', 
	CONCAT( CAST( MONTH(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date) AS varchar), '/', CAST( YEAR(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date) AS varchar) ) AS 'MonthYear_Temp',
	MONTH(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date) AS 'Month_Temp', YEAR(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date) AS 'Year_Temp'
	FROM dbo.Phoenix_Sky_Harbor_Daily_Temps
	GROUP BY YEAR(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date), MONTH(dbo.Phoenix_Sky_Harbor_Daily_Temps.Date)
)



SELECT monthly_count, Site, MonthYear_Count, Monthly_avg_high
FROM agg_counts
LEFT JOIN monthly_temp ON agg_counts.MonthYear_Count = monthly_temp.MonthYear_Temp
ORDER BY MonthYear_Count
