--We select the top 7 most visited trails.

SELECT *
FROM dbo.hiking
WHERE 
	dbo.hiking.Site = 'E - PMP - Piestewa Summit Trail' OR
	dbo.hiking.Site = 'E - Camelback - Echo Canyon Trail' OR
	dbo.hiking.Site = 'South Mountain-Pima Dirt Rd.' OR
	dbo.hiking.Site = 'E - Papago - Hole In The Rock' OR
	dbo.hiking.Site = 'N - North Mountain - 44-Tower Road' OR
	dbo.hiking.Site = 'N - Lookout Mountain - 306 - North Side TH' OR
	dbo.hiking.Site = 'South Mountain-Mormon Trail'
