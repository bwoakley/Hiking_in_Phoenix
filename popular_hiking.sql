-- We select the top 7 most visited trails.
-- Join with the daily max temp
-- Also clean by dropping rows where count < 10

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
