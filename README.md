# Hiking in Phoenix

## Summary
We investigate two data sets using popular Data Analysis tools: SQL and Tableau. The first data set consists of sensor data from various hiking trails in the city of Phoenix, Arizona. The data set can be found on the [City of Phoenix's Open Data Portal](https://www.phoenixopendata.com/dataset/hiking-trail-usage/resource/aa4e2a08-c0ad-4fc4-bee9-44c2d85a58fa). The sensors are set up along various trails in the city and count the number of hikers that use the trail. The data is "raw" in the sense that the sensors sometimes include errors or missing values. Therefore, our first step will be to load the data into a relational data base and query it with SQL to preprocess and clean the data. Additionally, we enrich this data set by joining a table containing the daily weather in Phoenix. This data set can be obtained from the [City of Mesa's Data Portal](https://citydata.mesaaz.gov/Environmental-and-Sustainability/Phoenix-Sky-Harbor-Daily-Temps/5auc-zhuc). The data comes from temperature readings at the Phoenix Sky Harbor Airport, and it includes maximum and minimum daily temperature. We use this data set to help explain some of the patterns in the hiking trends. Finally, we visualize our insights using the visualization software, Tableau.

## Files
The GitHub page for this project contains the following files. All code is written in SQL Server (version 16.0.1000).
- [ ] __popular_hiking.sql__ : Main file that extracts the most popular hiking trails and joins with the weather data
- [ ] __popular_hiking_aggregate.sql__ : Main file that returns the monthly average trail counts and monthly average max temperature
- [ ] __Misc\EDA1.sql__ - __Misc\EDA6.sql__ : SQL queries conducting Exploratory Data Analysis
- [ ] __Hiking_Trails_Counter.csv__ : Hiking Trails Counter data set
- [ ] __Phoenix_Sky_Harbor_Daily_Temps.csv__ : Phoenix Sky Harbor Daily Temps data set

## The Data Sets

Below, we see a header of both data sets considered in the project.
![image](Misc/datasets.jpg)

Each row of __Hiking_Trails_Counter.csv__ corresponds to a sensor reading. The features are the __Date__ of the reading, the __Site__ location, and the __Count__ of the number of hikers.
Notice that there are multiple readings for each __Date__ because there are multiple sensors.

Each row of __Phoenix_Sky_Harbor_Daily_Temps.csv__ is a summary of the temperature for the day. The features are the __Date__ of the reading, the maximum temperature for the day __MaxT__, the minimum temperature for the day __MinT__, and a sensor error flag __PIT_Flag__. This data set contains readings all the way back to the year 1900 and is an extremely interesting dataset to explore in its own right.


## Exploratory Data Analysis (EDA) with SQL

The files __Misc\EDA1.sql__, __Misc\EDA2.sql__, ...,  __Misc\EDA6.sql__ contain various SQL queries that explore the data and help define the scope of the project. We now outline some notable insights in the EDA files.



From __Misc\EDA1.sql__ :

	SELECT dbo.hiking.Site, COUNT(*) as 'Num_measured'
	FROM dbo.hiking
	GROUP BY dbo.hiking.Site
	ORDER BY dbo.hiking.Site
	

![image](Misc/table2_from_EDA1.jpg)

The above query uses the __GROUP BY__ statement to count the number of rows (measurements) corresponding to each site name. 

From this query, we see that there are 397 unique sites. Notice that many of the Sites are related. For example, "E - Dreamy Draw Park -Trail 100" and "E - Dreamy Draw Park -Trail 101" are in the same park, but they are different trails. 


From __Misc\EDA3.sql__ :

	
	SELECT COUNT(dbo.hiking.Date) AS 'Num of sites measured', dbo.hiking.Date  
	FROM dbo.hiking
	GROUP BY dbo.hiking.Date
	ORDER BY YEAR(dbo.hiking.Date), MONTH(dbo.hiking.Date), DAY(dbo.hiking.Date) 
	

![image](Misc/table_from_EDA3.jpg)

The above query groups by and orders by __Date__, counting the number of measurements per day.
We gain two insights from this query.

First, we notice that the data ranges from "1/1/2019" to "12/31/2022" and contains readings from every single day in that range.  We confirm that there are a total of 1461 days worth of data from "1/1/2019" to "12/31/2022".

Second, we also notice that the city researchers originally began with 46 sensors and ended the experiment with 43 sensors.

We are starting to understand the scope of the data set. We will now choose to narrow the focus of this project to study just a small number of the most popular trails. The following query computes the most popular trails:

From __Misc\EDA5.sql__ :


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

![image](Misc/table_from_EDA5.jpg)

The above query uses the __WITH__ clause to create two sub-query tables: __visits__ and __measured__. The  __visits__ table computes the total visits for each site, and the __measured__ table computes the number of times that each site was measured. We join these two temporary tables on the __Site__ name. Lastly, we order by total visits and times measured in descending order.

The output of this query shows the most popular sites together with the number of times measured. We see that the most popular trails were measured for all of the possible 1461 days. We decide to only consider the top 7 trails for the rest of this project. We make this choice for three reasons. 

First, by choosing the most popular trails, we make our analysis more robust to error. For example, if a given trail usually receives 2000+ hikers, suddenly receives < 10 hikers for a few days, and then continues with the usual pattern of 2000+ hikers from then on, then we can be confident that this pattern is due to a sensor error.

Second, we choose trails that were measured for all 1461 days. The city researches did move the sensors for some of the sites, but measured other sites every day. By focusing our study on the sites that were measured daily, we will make it easier to spot the seasonal patterns in the data.

Third, we choose to focus the study on a small number of sites. The visualizations in Tableau are vastly simplified, as we will see later. We do not need all of the sites in order to tell the story we want to tell with these data sets.

## Preprocessing and Cleaning with SQL

![image](Misc/table_from_popular_hiking.jpg)


## Visualization with Tableau



## References
- [ ] The Hiking Trails Counter data set is found at: [City of Phoenix's Open Data Portal](https://www.phoenixopendata.com/dataset/hiking-trail-usage/resource/aa4e2a08-c0ad-4fc4-bee9-44c2d85a58fa)
- [ ]  The Phoenix Sky Harbor Daily Temps data set is found at: [City of Mesa's Data Portal](https://citydata.mesaaz.gov/Environmental-and-Sustainability/Phoenix-Sky-Harbor-Daily-Temps/5auc-zhuc)




















