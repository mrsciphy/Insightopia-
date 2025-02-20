-- 1.	How does batch processing time compare to the minimum batch time for each product?
with downtime as (
SELECT 
    lp.Batch, 
    lp.Product, 
    lp.Batch_duration_time, 
    p.[Min batch time],
    lp.batch_duration_time - p.[Min batch time] AS time_difference,
	sum(lds.downtime_minutes) as downtime_minutes
	FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
join Line_downtime_structured lds on lp.batch = lds.batchid
group by lp.Batch, lp.product, lp.Batch_duration_time, p.[Min batch time]
)

select * from downtime;

SELECT 
    lp.Batch, 
    lp.Product, 
    lp.Batch_duration_time, 
    p.[Min batch time],
    lp.batch_duration_time - p.[Min batch time] AS time_difference,
	sum(lds.downtime_minutes) as downtime_minutes
	FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
join Line_downtime_structured lds on lp.batch = lds.batchid
group by lp.Batch, lp.product, lp.Batch_duration_time, p.[Min batch time]
ORDER BY lp.Batch, lp.Product;

-- 2. How Many Batches were Produced Per Day? 
select 
	cast([Date] as date) as day,
	count(distinct batch) as batch_count 
from ['Line_productivity]
group by cast([Date] as date)
order by day;

SELECT cast(Date as date) Date, COUNT(Batch) AS Total_Batches
FROM ['Line_productivity]
GROUP BY Date
ORDER BY Date;


-- 3. What is the total production time per operator? 
select 
	operator, sum(batch_duration_time) as total, 
	count(batch) as No_of_batches,
	round(COUNT(Batch) * 100.0 / SUM(COUNT(Batch)) OVER (), 2) AS PercentageOfTotal
from ['Line_productivity]
group by Operator
order by Operator;

SELECT Operator, SUM(DATEDIFF(MINUTE,[Start Time], [End Time])) AS Total_Production_Time
FROM ['Line_productivity]
GROUP BY Operator;

-- 4. Find batches that exceeded the minimum batch time 
SELECT 
    lp.Batch, p.[Min batch time], lp.Batch_duration_time
	FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
where lp.Batch_duration_time > p.[Min batch time]

ORDER BY lp.Batch, lp.Product


-- batches with no downtime 
SELECT 
    lp.Batch, p.[Min batch time], lp.Batch_duration_time
	FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
where lp.Batch_duration_time <= p.[Min batch time]

ORDER BY lp.Batch, lp.Product

-- 5. Which has the highest number of batches? (with efficiency) 
-- product:
SELECT 
    Product, 
    COUNT(Batch) AS TotalBatches FROM ['Line_productivity]
GROUP BY Product
ORDER BY TotalBatches DESC;

-- 6. What are the avg/sum/max production time per product type? 
SELECT
	p.Product, p.Size,
	avg(lp.Batch_duration_time) AS Avg_Batch_Time, 
	sum(lp.batch_duration_time) as totaltime, 
	max(lp.batch_duration_time) as highest_time
FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
GROUP BY p.Product, p.Size
order by totaltime;
--per flavor
SELECT
	p.Flavor, 
	avg(lp.Batch_duration_time) AS Avg_Batch_Time, 
	sum(lp.batch_duration_time) as totaltime, 
	max(lp.batch_duration_time) as highest_time
FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product
GROUP BY p.Flavor;
--per shift (depends on the start time)
WITH ShiftedData AS (
    SELECT 
        [Start Time],
        Batch_duration_time,
        CASE 
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 0 AND 7 THEN 'Night'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 8 AND 15 THEN 'Morning'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 16 AND 23 THEN 'Evening'
        END AS Shift
    FROM ['Line_productivity]
    WHERE Batch_duration_time IS NOT NULL
)
SELECT 
    Shift,
    AVG(Batch_Duration_time) AS Average_Batch_Duration
FROM ShiftedData
GROUP BY Shift
ORDER BY Shift;

-- per each batch
SELECT
	p.Product, lp.Batch, lp.batch_duration_time 
FROM ['Line_productivity] lp
JOIN Products p ON lp.Product = p.Product;

-- 7. Are there significant differences in batch processing time between different shifts?
SELECT 
    Date, operator, sum(batch_duration_time) as total,
    AVG(Batch_duration_time) AS AvgProcessingTime,
    MIN(Batch_duration_time) AS MinProcessingTime,
    MAX(Batch_duration_time) AS MaxProcessingTime,
    COUNT(Batch) AS TotalBatches
FROM 
    ['Line_productivity]
GROUP BY 
    Date, Operator
ORDER BY 
    date DESC;

-- 8. Which batch have the longest production time?
SELECT 
    Batch,
    sum(Batch_duration_time) AS highest_production_time
FROM 
    ['Line_productivity]
GROUP BY 
    Batch
ORDER BY 
    highest_production_time DESC;

-- 9. How does productivity vary throughout the day?
SELECT 
    DATEPART(HOUR, [Start Time]) AS HourOfDay, 
    COUNT(Batch) AS TotalBatches, 
    avg(Batch_duration_time) AS AvgProcessingTime,
	sum(Batch_duration_time) as totaltime
FROM 
    ['Line_productivity]
GROUP BY 
    DATEPART(HOUR, [Start Time])
ORDER BY 
    HourOfDay;

-- 10. What are the most common downtime factors?
-- 11. How much time is lost due to each downtime factor?
-- 12. Are operator errors a major contributor to downtime? 
select df.factor, df.description, sum(lds.downtime_minutes) as total_time, count(lds.downtime_factor) AS Occurrences, df.[Operator Error]
from ['Downtime_factors'] df 
join Line_downtime_structured lds on df.factor = lds.Downtime_factor
where df.[Operator Error] = 'Yes'
group by Factor, description, [Operator Error]
order by total_time desc

-- 13. Which products experience the most downtime? 
select lp.Product, sum(lds.downtime_minutes) as downtime_minutes
from ['Line_productivity] lp
join Line_downtime_structured lds on lp.Batch = lds.BatchID
group by lp.Product
order by downtime_minutes;

-- 14. What is the average downtime per batch?
select batchid, avg(downtime_minutes) as avg_DTmin, sum(downtime_minutes) as total_downtime
from Line_downtime_structured
group by BatchID
order by avg_DTmin;

-- 15. Which operators have the highest and lowest downtime incidents?
select lp.Operator, sum(lds.downtime_minutes) as total_time
from ['Line_productivity] lp
join Line_downtime_structured lds on lds.BatchID = lp.Batch
join ['Downtime_factors'] df on df.factor = lds.Downtime_factor 
where df.[Operator Error] = 'Yes'
group by lp.Operator
order by total_time desc

-- details about the downtime for each operator:
--16. Are certain downtime factors linked to specific operators? (No)
select lp.Operator, sum(lds.downtime_minutes) as total_time, df.factor, df.description
from ['Line_productivity] lp
join Line_downtime_structured lds on lds.BatchID = lp.Batch
join ['Downtime_factors'] df on df.factor = lds.Downtime_factor 
where df.[Operator Error] = 'Yes'
group by df.Factor, df.Description, lp.Operator
order by total_time desc

-- 17. Is there a correlation between batch duration and downtime?
WITH CorrelationData AS (
    SELECT 
        lp.Batch_duration_time,
        lds.downtime_minutes
    FROM ['Line_productivity] lp
	join Line_downtime_structured lds on lp.Batch = lds.BatchID
    WHERE lp.Batch_duration_time IS NOT NULL 
      AND lds.downtime_minutes IS NOT NULL
)
SELECT 
    (COUNT(*) * SUM(Batch_duration_time * downtime_minutes) 
     - SUM(Batch_duration_time) * SUM(downtime_minutes)) /
    (SQRT((COUNT(*) * SUM(Batch_duration_time * Batch_duration_time) 
           - POWER(SUM(Batch_duration_time), 2)) * 
          (COUNT(*) * SUM(downtime_minutes * downtime_minutes) 
           - POWER(SUM(downtime_minutes), 2)))) AS Correlation_Coefficient
FROM CorrelationData;

-- 18. Are there patterns in downtime based on the time of day?
WITH ShiftedData AS (
    SELECT 
        Batch,
		[Start Time],
        Batch_duration_time,
        CASE 
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 0 AND 7 THEN 'Night'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 8 AND 15 THEN 'Morning'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 16 AND 23 THEN 'Evening'
        END AS Shift
    FROM ['Line_productivity]
    WHERE Batch_duration_time IS NOT NULL
)
SELECT 
    sd.Shift,
    sum(lds.downtime_minutes) as downtimeMin
FROM ShiftedData sd
join Line_downtime_structured lds on sd.Batch = lds.BatchID
GROUP BY Shift
ORDER BY Shift;

--19. What is the overall efficiency of the manufacturing line (productive time vs. downtime)?
select 
	sum(lp.Batch_duration_time) as totalProductionTime,
	sum(lds.downtime_minutes) as totalDowntime,
	sum(lp.Batch_duration_time)*100/(sum(lp.Batch_duration_time)+ sum(lds.downtime_minutes)) as Efficiency
from Line_downtime_structured lds
join ['Line_productivity] lp on lp.Batch = lds.BatchID


