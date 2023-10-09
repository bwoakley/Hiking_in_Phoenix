-- We confirm that we have imported all 65195 records:
select COUNT(*) as 'Num_records'
from dbo.hiking


-- How many different sites are there? There are 397 of them:
SELECT dbo.hiking.Site, COUNT(*) as 'Num_measured'
FROM dbo.hiking
GROUP BY dbo.hiking.Site
ORDER BY dbo.hiking.Site
-- Notice that many of the Sites are related. 
-- For example, "E - PMP - Trail 9144" and "E - PMP - Trail 3320" are in the same park, but different trails.




