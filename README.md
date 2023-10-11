# Hiking in Phoenix

## Summary

I recently moved to Phoenix, Arizona for work, and I am eager to learn more about the city and and its culture. As an avid hiker and data scientist, I found that studying the trends of Pheonix's vibrant and active population is a natural way to discover interesting activities and meet like-minded individuals. 

In this project, I use the popular Data Analysis tools __SQL__ and __Tableau__ to investigate which hiking trails in the city are most popular and what factors may influence that activity. Some fun insights and conclusions that we will discover in this project are that there is a significant correlation between number of hikers on the trails and the weather (most of the hiking happens in Phoenix's winters) and that there is much more hiking happening on the weekends. We will also see that some hiking trails are still active in the summer, indicating that the trail may be shady and a way to escape the heat! 

## Description

We investigate two data sets using popular Data Analysis tools: SQL and Tableau. The first data set consists of sensor data from various hiking trails in the city of Phoenix, Arizona. The data set can be found on the [City of Phoenix's Open Data Portal](https://www.phoenixopendata.com/dataset/hiking-trail-usage/resource/aa4e2a08-c0ad-4fc4-bee9-44c2d85a58fa). The sensors are set up along various trails in the city and count the number of hikers that use the trail. The data is "raw" in the sense that the sensors sometimes include errors or missing values. Therefore, our first step will be to load the data into a relational data base and query it with SQL to preprocess and clean the data. 

Additionally, we enrich this data set by joining a table containing the daily weather in Phoenix. This data set can be obtained from the [City of Mesa's Data Portal](https://citydata.mesaaz.gov/Environmental-and-Sustainability/Phoenix-Sky-Harbor-Daily-Temps/5auc-zhuc). The data comes from temperature readings at the Phoenix Sky Harbor Airport, and it includes maximum and minimum daily temperature. We use this data set to help explain some of the patterns in the hiking trends. Finally, we visualize our insights using the visualization software, Tableau. You can skip directly to the [Visualization with Tableau section by clicking here](#visualization-with-tableau).


## Files
The GitHub page for this project contains the following files. All code is written in SQL Server (version 16.0.1000).
- [ ] __SQL_code__ folder :
	- [ ] __popular_hiking*.sql__ : Main SQL files that extract the most popular hiking trails, join with the weather data, and perform various feature engineering
- [ ] __EDA_SQL__ folder :
	- [ ] __EDA1.sql__ ... __EDA6.sql__ : SQL queries conducting Exploratory Data Analysis
- [ ] __Datasets__ folder :
	- [ ] __Hiking_Trails_Counter.csv__ : Hiking Trails Counter data set
	- [ ] __Phoenix_Sky_Harbor_Daily_Temps.csv__ : Phoenix Sky Harbor Daily Temps data set
	- [ ] __popular_hiking*.csv__ : Tables generated from the SQL queries in the __SQL_code__ folder

## The Data Sets

Below, we see a header of both data sets considered in the project.
![image](Images/datasets.jpg)

Each row of __Hiking_Trails_Counter.csv__ corresponds to a sensor reading. The features are the __Date__ of the reading, the __Site__ location, and the __Count__ of the number of hikers.
Notice that there are multiple readings for each __Date__ because there are multiple sensors.

Each row of __Phoenix_Sky_Harbor_Daily_Temps.csv__ is a summary of the temperature for the day. The features are the __Date__ of the reading, the maximum temperature for the day __MaxT__, the minimum temperature for the day __MinT__, and a sensor error flag __PIT_Flag__. This data set contains readings all the way back to the year 1900 and is an extremely interesting dataset to explore in its own right.


## Exploratory Data Analysis (EDA) with SQL

The files __EDA1.sql__, __EDA2.sql__, ...,  __EDA6.sql__ contain various SQL queries that explore the data and help define the scope of the project. We now outline some notable insights in the EDA files.



From __EDA1.sql__ :

	SELECT dbo.hiking.Site, COUNT(*) as 'Num_measured'
	FROM dbo.hiking
	GROUP BY dbo.hiking.Site
	ORDER BY dbo.hiking.Site
	

![image](Images/table2_from_EDA1.jpg)

The above query uses the __GROUP BY__ statement to count the number of rows (measurements) corresponding to each site name. 

From this query, we see that there are 397 unique sites. Notice that many of the Sites are related. For example, "E - Dreamy Draw Park -Trail 100" and "E - Dreamy Draw Park -Trail 101" are in the same park, but they are different trails. 


From __EDA3.sql__ :

	
	SELECT COUNT(dbo.hiking.Date) AS 'Num of sites measured', dbo.hiking.Date  
	FROM dbo.hiking
	GROUP BY dbo.hiking.Date
	ORDER BY YEAR(dbo.hiking.Date), MONTH(dbo.hiking.Date), DAY(dbo.hiking.Date) 
	

![image](Images/table_from_EDA3.jpg)

The above query groups by and orders by __Date__, counting the number of measurements per day.
We gain two insights from this query.

First, we notice that the data ranges from "1/1/2019" to "12/31/2022" and contains readings from every single day in that range.  We confirm that there are a total of 1461 days worth of data from "1/1/2019" to "12/31/2022".

Second, we also notice that the city researchers originally began with 46 sensors and ended the experiment with 43 sensors.

We are starting to understand the scope of the data set. We will now choose to narrow the focus of this project to study just a small number of the most popular trails. The following query computes the most popular trails:

From __EDA5.sql__ :


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

![image](Images/table_from_EDA5.jpg)

The above query uses the __WITH__ clause to create two sub-query tables: __visits__ and __measured__. The  __visits__ table computes the total visits for each site, and the __measured__ table computes the number of times that each site was measured. We join these two sub-query tables on the __Site__ name. Lastly, we order by total visits and times measured in descending order.

The output of this query shows the most popular sites together with the number of times measured. We see that the most popular sites were measured for all of the possible 1461 days. We decide to only consider the top 7 sites for the rest of this project. We make this choice for three reasons:

- [ ] First, by choosing the most popular sites, we make our analysis more robust to error. For example, if a given site usually receives 2000+ hikers, suddenly receives < 10 hikers for a few days, and then continues with the usual pattern of 2000+ hikers from then on, then we can be confident that this pattern is due to a sensor error.

- [ ] Second, we choose sites that were measured for all 1461 days. The city researches did move the sensors for some of the sites, but measured other sites every day. By focusing our study on the sites that were measured daily, we will make it easier to spot the seasonal patterns in the data.

- [ ] Third, we choose to focus the study on a small number of sites. The visualizations in Tableau are vastly simplified, as we will see later. We do not need all of the sites in order to tell the story we want to tell with these data sets.

## Preprocessing and Cleaning with SQL

Now that we have finished our Exploratory Data Analysis, we will now need to preprocess and clean the data before it is ready to be loaded into Tableau for visualization. This work is done in our main SQL files in the  __SQL_code__ folder. We begin with __popular_hiking.sql__, which extracts the most popular hiking trails and joins with the weather data.

From __popular_hiking.sql__ :  

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


![image](Images/table_from_popular_hiking.jpg)

In the above table, we have the __Date__, __Site__, and __Count__ of each measurement, as usual. We also see the __MaxT__ feature, which was added using a __LEFT JOIN__ to join the __Phoenix_Sky_Harbor_Daily_Temps__ data set. We also have two other new features.

First, we have the __is_weekend_day__ feature, which is 1 if that day is a weekend and is 0 if that day is a week day. This feature will allow us to see the trend that people hike more on the weekends, as we will see later when we discuss the Tableau visualization. We compute this feature in the select window using a __CASE__ expression and the __DATEPART__ function.

Second, we have the __how_hot__ feature. The value of this feature is one of 5 categories depending on the value of __MaxT__.  We again use a __CASE__ expression in the select window to assign each day one of the 5 values: "Why are you hiking?", "Too hot", "Hot", "Warm", or "Ideal".  For example, the category "Why are you hiking?" corresponds to a day where the maximum temperature was more than 110 degrees, and the category "Ideal" corresponds to a day where the maximum temperature was 80 degrees or less. This purpose of binning the __MaxT__ feature to create the __how_hot__ feature is to simplify the visualizations in Tableau, as we will see later.

Lastly, we use the the __WHERE__ clause at the end of the query to do two things. First, we only want to select from our top 7 sites, as discussed previously. Second, we want to clean the data. We select measurements where __Count__ > 10 to trim off measurements where the sensor was clearly malfunctioning. Additionally, we want to  only select entries with __Count__ < 2500. This trims off some of the influential outliers in the data set. There were several days with very large hiker counts, possibly due to some special event or a sensor error. These outliers were causing issues with the linear regression analysis in Tableau, so it is best to drop them.

We will also consider an aggregated version of the above table, as we will discuss now:

From __popular_hiking_aggregate.sql__ :

	

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

![image](Images/table_from_popular_hiking_agg.jpg)

The above SQL query uses the __WITH__ clause to create three sub-query tables: __clean_records__, __agg_counts__, and  __monthly_temp__. 

The first of these, __clean_records__, simply preprocesses and cleans the hiking data the same way as the query we just discussed in __popular_hiking.sql__. The __agg_counts__ table computes the monthly average of __Count__ for each __Site__, and the  __monthly_temp__ table computes the monthly average of __MaxT__ for each day.

We join __agg_counts__ and __monthly_temp__ to produce a table that simply reports the average monthly visits for our popular sites along with the monthly high temperature. 

The reason we compute this aggregated table is to clean the records. Since the sensors are known to give inaccurate reports some days, we believe that aggregating the data will average out those inaccurate readings. The average __Count__ should more precisely reflect the true __Count__ for each site. This allows for a better linear regression fit (depending on the site) with less noise, as we will see in our "Visualization with Tableau" section below.

The other two files in the __SQL_code__ folder use similar SQL queries. Namely, __popular_hiking_weekend.sql__ computes the average hiker __Count__ on weekdays versus weekends, aggregated monthly. Lastly, __popular_hiking_aggregateTemp__ computes the average hiker __Count__ aggregated over __Site__ and __MaxT__. 



## Visualization with Tableau

See the [Phoenix Hiking Viz](https://public.tableau.com/views/PhoenixHikingViz/PopularHiking?:language=en-US&:display_count=n&:origin=viz_share_link) on my Tableau Public profile. This visualization is a story with two pages, and it is interactive. It would be best to view and interact with the story dashboard on my Tableau Public page, but for purposes of this write-up, we will now look at still images of the visualization.

The first page is:

![image](Images/story_1.jpg)

We now wish to discuss the __insights__ gained from this page of the visualization. 

Notice that the first graph depicts the Monthly Share by Site, the monthly hiker count numbers for the 7 most popular hiking sites. There is a seasonal trend, where __people hike more in the winter__. Let's explore that trend further. 

In the third graph, we see Hiking Count by Weather Category. Most of the hiking occurs in the blue zone, when the weather is categorized as "Ideal", that is 80 degrees Fahrenheit or less. 

In the fourth graph, you also see the Monthly Max Temp. During the summer, the Max Temp gets above 110 degrees! As one would expect, there is much less total hiking during the Summer.

The second graph, Hiking Count on Weekday vs Weekend shows a different kind of trend in the hiker counts: __people hike more on the weekend__. The graph shows the daily average hiker count on the weekend in orange and the daily average hiker count on the weekday in blue. During the winter, there is almost twice as much hiking happening on the weekend as there is during the weekday. Surprisingly, this phenomenon does not extend to the summer. There is not much difference between weekday and weekend hiking in the summer. 

The second page of the story is:

![image](Images/story_2.jpg)

Concerning the insights gained from this page of the visualization, we first observe that there is a negative correlation between the hiker count and max temperature for all hiking sites. That is, __an increase in max temperature corresponds to a decrease in hiker count__.  This can be seen in the first two graphs.

The graph on the top left is a Scatter Plot of Daily Counts vs Max Temp. You can see the general downward trend in Count as we move to the right along the Max Temp axis.

The graph on the top right is the Monthly Count vs Monthly Max Temp. We aggregate the count and temperature data to average out the sensor error noise, as discussed in the previous section. This allows us to more easily see the downward trend and fit a line of best fit using linear regression within Tableau Analytics. Notice that the red and green line in this graph do not have the same slope. This leads us to a second insight: __some hiking sites are not affected as much by increased temperature__. Notice that the red line has a steep slope, so an increase in max temperature is related to a large decrease in hiker count for the E - PMP - Piestewa Summit Trail. However the green line is much flatter of a slope, implying that an increase in max temperature does not decrease hiker count by much for the 
N - North Mountain - 44-Tower Road trail. Perhaps this North Mountain trail is shady, and so the hikers are willing to hike even if it is too hot? This is a discovery that I may try out myself this next summer for my own hikes!

The bottom graph, Average Count given fixed Max Temp, helps us visualize one more pattern. The graph plots the Average Count for a given Max Temperature value. That is, take the graph on the top left and collapse all of the data points vertically by taking an average of the Count for each Max Temp value. This helps us average out the variation in hiker count and try to understand how the average count varies depending on the max temperature. We see an interesting pattern: __hikers don't want to hike if it is too cold__. The curve plotted is a degree 3 polynomial of best fit using linear regression within Tableau Analytics. The curve peaks at around 72 degrees. From 72 degrees, increasing the temperature slowly decreases hiker count (the curve has a shallow slope). However, from 72 degrees, decreasing the temperature rapidly decreases hiker count (the curve has a steep slope).

## Conclusions

We have used SQL queries to process our data and Tableau to visualize the data. Both were necessary steps in this analysis project. The SQL queries helped us understand the scope of the data through Exploratory Data Analysis, and they helped us manipulate the data so that it is in a format useful for Tableau. Through the Tableau visualizations, we discovered various insights:
- [ ] people hike more in the winter
- [ ] people hike more on the weekend
- [ ] an increase in max temperature corresponds to a decrease in hiker count
- [ ] some hiking sites are not affected as much by increased temperature
- [ ] hikers don’t want to hike if it is too cold

Some of these insights may seem obvious, but it is important to note that these are evidence based insights backed up by the data. Indeed, one could use statistics to measure the validity of these insights, providing numerical estimates and confidence intervals.

Thank you for reading this project write-up! Take care. : )


## References
- [ ] The Hiking Trails Counter data set is found at: [City of Phoenix's Open Data Portal](https://www.phoenixopendata.com/dataset/hiking-trail-usage/resource/aa4e2a08-c0ad-4fc4-bee9-44c2d85a58fa)
- [ ]  The Phoenix Sky Harbor Daily Temps data set is found at: [City of Mesa's Data Portal](https://citydata.mesaaz.gov/Environmental-and-Sustainability/Phoenix-Sky-Harbor-Daily-Temps/5auc-zhuc)
