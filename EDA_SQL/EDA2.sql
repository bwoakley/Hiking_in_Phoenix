-- I only see 46 distinct sites on 1/1/2019:
SELECT dbo.hiking.Site
FROM dbo.hiking
WHERE dbo.hiking.Date = '1/1/2019'
-- This means, they keep moving the sensors.


-- How often do they sample a given site. The first site is "E - Camelback - Cholla Trail". Let's follow it:
SELECT * 
FROM dbo.hiking
WHERE dbo.hiking.Site = 'E - Camelback - Cholla Trail'			-- AND dbo.hiking.Count > 0
ORDER BY dbo.hiking.Date
-- There are 1461 entries.
-- In the count of hikers, there are null valued or 0 entries. Sometimes the count is unusually small, < 20 hikers.
-- A null value or 0 entry indicates there was a sensor error on that day and data could not be accuratly collected.




