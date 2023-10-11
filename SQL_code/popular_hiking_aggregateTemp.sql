WITH clean_records AS (
	SELECT dbo.hiking.Date, dbo.hiking.Site, dbo.hiking.Count,  dbo.Phoenix_Sky_Harbor_Daily_Temps.MaxT
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
)

SELECT AVG(Count) AS Average_Count, MaxT, Site
FROM clean_records
GROUP BY MaxT, Site
ORDER BY MaxT