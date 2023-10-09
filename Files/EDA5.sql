
-- Compute the most popular trails
WITH visits AS (
	SELECT SUM(dbo.hiking.Count) AS total_visits, dbo.hiking.Site AS v_site
	FROM dbo.hiking
	GROUP BY dbo.hiking.Site
),

measured AS (
	SELECT COUNT(*) as times_measured, dbo.hiking.Site AS m_site
	FROM dbo.hiking
	GROUP BY dbo.hiking.Site
	--ORDER BY Num_measured DESC, dbo.hiking.Site
)

SELECT visits.total_visits, measured.times_measured, visits.v_site AS Site
FROM visits
LEFT JOIN measured ON visits.v_site = measured.m_site
ORDER BY visits.total_visits DESC, measured.times_measured DESC
