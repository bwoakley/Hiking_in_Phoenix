SELECT dbo.hiking.Site, COUNT(*) as 'Num_measured'
FROM dbo.hiking
GROUP BY dbo.hiking.Site
ORDER BY Num_measured DESC, dbo.hiking.Site
-- 35 Sites were measured every day
-- Let's start by focusing on just a few of those trails