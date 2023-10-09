 -- Still following "E - Camelback - Cholla Trail", we ask did they try to detect hikers on every day? 
 -- How many days are there from the first to last reading? 
 SELECT COUNT(dbo.hiking.Date) AS 'Num of sites measured', dbo.hiking.Date  
 FROM dbo.hiking
 GROUP BY dbo.hiking.Date
 ORDER BY YEAR(dbo.hiking.Date), MONTH(dbo.hiking.Date), DAY(dbo.hiking.Date) 
 -- We confirm that there are a total of 1461 days worth of data from "1/1/2019" to "12/31/2022".
 -- We also notice that the group originally began with 46 sensors and ended the experiment with 43 sensors.


 


