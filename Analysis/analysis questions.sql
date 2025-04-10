-- 1.How does batch processing time compare to the minimum batch time for each product? 
-- What are the top 10 batches exceeding the minimum batch time? 
SELECT top (10)
    lp.Operator,
	lp.Batch, 
    lp.Product, 
    lp.Batch_duration_time 
    --p.[Min batch time] as production_time,
    ,lp.batch_duration_time - p.[Min batch time] AS downtime
	/*,sum(lds.downtime_minutes) as downtime_minutes,
	count([Downtime_factor]) as frequency_of_downtime*/
	FROM [Line productivity] lp
jOIN Products p ON lp.Product = p.Product
--join Line_downtime_structured lds on lp.batch = lds.batchid
--group by lp.Batch, lp.product, lp.Batch_duration_time, p.[Min batch time], lp.Operator, lds.Downtime_factor
ORDER BY downtime desc;

-- What is the cycle time (minutes per patch)
select
	sum(lp.Batch_duration_time) as Manufacturing_time,
	count(lp.batch) as 'No. of batches',
	sum(lp.Batch_duration_time) / count(lp.batch) as Total_cycle_time
from [Line productivity] lp
Join products p on p.Product = lp.Product

SELECT 
    SUM(agg_prod.BatchDuration) AS totalProductionTime,
    SUM(agg_downtime.totalDowntime) AS totalDowntime,
    ROUND((SUM(agg_prod.BatchDuration) - SUM(agg_downtime.totalDowntime)) / 
          NULLIF(count(agg_prod.No_of_batches), 0), 2) AS "Cycle time"
FROM 
    (SELECT Batch, SUM(Batch_duration_time) AS BatchDuration, count(batch) as No_of_batches
     FROM [Line productivity]
     GROUP BY Batch) agg_prod
LEFT JOIN 
    (SELECT BatchID, SUM(downtime_minutes) AS totalDowntime
     FROM Line_downtime_structured
     GROUP BY BatchID) agg_downtime
ON agg_prod.Batch = agg_downtime.BatchID;

-- 2. Are there batches didn’t exceed the minimum batch time (with no downtime)? 
SELECT 
    lp.Batch, lp.Product, lp.Date, lp.Operator, p.[Min batch time], lp.Batch_duration_time, lp.[Start Time]
	FROM [Line productivity] lp
JOIN Products p ON lp.Product = p.Product
where lp.Batch_duration_time <= p.[Min batch time]
ORDER BY lp.Batch, lp.Product

-- 3. How Many Batches were Produced Per Day? 
select 
	cast([Date] as date) as day,
	count(distinct batch) as batch_count 
from [Line productivity]
group by cast([Date] as date)
order by day;
--another code for Q3
SELECT cast(Date as date) Date, COUNT(Batch) AS Total_Batches
FROM [Line productivity]
GROUP BY Date
ORDER BY Date;

-- 4. What is the total production time per operator? 
select 
	lp.operator, sum(lp.batch_duration_time) as duration_time, sum(p.[Min batch time]) as production_time,
	count(lp.batch) as No_of_batches
	,round(sum(p.[Min batch time]) * 100.0 / sum(lp.batch_duration_time), 2) AS efficiency
	--,sum(lds.[downtime_minutes])
from [Line productivity] lp
join Products p on p.[Product] = lp.[Product]
--right join line_downtime_structured lds on lp.batch = lds.batchID
group by Operator
order by Operator;

--another code for Q4 (not accurate)
SELECT Operator, SUM(DATEDIFF(MINUTE,[Start Time], [End Time])) AS Total_Production_Time
FROM [Line productivity]
GROUP BY Operator;

-- 5. Which product has the highest number of batches?
SELECT 
    Product, 
    COUNT(Batch) AS TotalBatches FROM [Line productivity]
GROUP BY Product
ORDER BY TotalBatches DESC;

-- 6. What is the production time per
-- per product?
SELECT
	p.Product, p.Size,
	sum(lp.batch_duration_time) as DurationTime, 
	--avg(lp.Batch_duration_time) AS Avg_Batch_Time, 
	SUM(p.[Min batch time]) as production_time, 
	round((SUM(p.[Min batch time])*100)/sum(lp.batch_duration_time), 2) as 'efficiency (%)'
FROM [Line productivity] lp
JOIN Products p ON lp.Product = p.Product
GROUP BY p.Product, p.Size
order by p.Product;
--per flavor
SELECT
	p.Flavor, 
	sum(lp.batch_duration_time) as DurationTime, 
	--avg(lp.Batch_duration_time) AS Avg_Batch_Time,
	SUM(p.[Min batch time]) as production_time,
		round((SUM(p.[Min batch time])*100)/sum(lp.batch_duration_time), 2) as 'efficiency (%)'
FROM [Line productivity] lp
JOIN Products p ON lp.Product = p.Product
GROUP BY p.Flavor;
--per shift (depends on the start time)?
WITH ShiftedData AS (
    SELECT 
        [Start Time],
        Batch_duration_time,
		p.[Min batch time] as Production_time,
        CASE 
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 0 AND 7 THEN 'Night'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 8 AND 15 THEN 'Morning'
            WHEN DATEPART(HOUR, [Start Time]) BETWEEN 16 AND 23 THEN 'Evening'
        END AS Shift
    FROM [Line productivity] lp
	join Products p on lp.Product = p.Product
    WHERE Batch_duration_time IS NOT NULL
)
SELECT 
    Shift,
    --AVG(Batch_Duration_time) AS Average_Batch_Duration,
	sum(Batch_duration_time) as Duration_time,
	sum(Production_time) as production_time,
	round((SUM(sd.Production_time)*100)/sum(sd.batch_duration_time), 2) as 'efficiency (%)'
FROM ShiftedData sd
GROUP BY Shift
ORDER BY Shift;

-- 7. Are there significant differences in batch processing time between different days?
SELECT 
    lp.Date,
    round(sum(p.[Min batch time])/60, 2) AS 'productivity (hrs)',
    COUNT (lp.Batch) AS TotalBatches,
	round(sum(lp.batch_duration_time)/60, 2) as 'Duration (hours)',
	round(sum(p.[Min batch time])*100/sum(lp.batch_duration_time),2) as 'efficiency per day'
FROM 
    [Line productivity] lp
join products p on lp.Product = p.Product
GROUP BY lp.Date ORDER BY lp.Date DESC;

-- 8. How does productivity vary throughout the day?
SELECT
    DATEPART(HOUR, [Start Time]) AS 'Hour No', 
    COUNT(Batch) AS TotalBatches, 
    avg(Batch_duration_time) AS 'AvgProcessingTime (min)'
	--,sum(Batch_duration_time) as totaltime
FROM 
    [Line productivity]
GROUP BY 
    DATEPART(HOUR, [Start Time])
ORDER BY 
    [Hour No];

-- 9. What are the most common downtime factors?
-- 10. How much time is lost due to each downtime factor?
-- 11. Are operator errors a major contributor to downtime? 
-- due to operator error
select df.description, sum(lds.downtime_minutes) as total_downtime, count(lds.downtime_factor) AS 'No. of Occurrence'
from [Downtime factors] df 
join Line_downtime_structured lds on df.factor = lds.Downtime_factor
where df.[Operator Error] = 'Yes'
group by description
order by total_downtime desc;
-- Not due to operator error
select df.description, sum(lds.downtime_minutes) as total_downtime, count(lds.downtime_factor) AS 'No. of Occurrence'
from [Downtime factors] df 
join Line_downtime_structured lds on df.factor = lds.Downtime_factor
where df.[Operator Error] = 'No'
group by description
order by total_downtime desc;

-- 12. is there any downtime factor that has no impact on the productivity? (Yes)
select df.Factor, df.description
from [Downtime factors] df
left join Line_downtime_structured lds on df.Factor = lds.Downtime_factor
where lds.Downtime_factor is null
group by df.Factor, df.Description

-- 13. Which products experience the most downtime? 
select lp.Product, sum(lds.downtime_minutes) as downtime_minutes
from [Line productivity] lp
join Line_downtime_structured lds on lp.Batch = lds.BatchID
group by lp.Product
order by downtime_minutes;

-- 14. Which operators have the highest and lowest downtime incidents?
select lp.Operator, sum(lds.downtime_minutes) as total_Downtime
from [Line productivity] lp
left join Line_downtime_structured lds on lds.BatchID = lp.Batch
left join [Downtime factors] df on df.factor = lds.Downtime_factor 
where df.[Operator Error] = 'No'
group by lp.Operator
order by total_Downtime desc

-- details about the downtime for each operator:
--15. Are certain downtime factors linked to specific operators? (No)
select lp.Operator, sum(lds.downtime_minutes) as total_time, df.description
from [Line productivity] lp
join Line_downtime_structured lds on lds.BatchID = lp.Batch
join [Downtime factors] df on df.factor = lds.Downtime_factor 
where df.[Operator Error] = 'No'
group by df.Description, lp.Operator
order by total_time desc

-- 16. Is there a correlation between batch duration and downtime?
WITH CorrelationData AS (
    SELECT 
        lp.Batch_duration_time,
        lds.downtime_minutes
    FROM [Line productivity] lp
	join Line_downtime_structured lds on lp.Batch = lds.BatchID
    WHERE lp.Batch_duration_time IS NOT NULL 
      AND lds.downtime_minutes IS NOT NULL
)
SELECT 
    round((COUNT(*) * SUM(Batch_duration_time * downtime_minutes) 
     - SUM(Batch_duration_time) * SUM(downtime_minutes)) /
    (SQRT((COUNT(*) * SUM(Batch_duration_time * Batch_duration_time) 
           - POWER(SUM(Batch_duration_time), 2)) * 
          (COUNT(*) * SUM(downtime_minutes * downtime_minutes) 
           - POWER(SUM(downtime_minutes), 2)))),2) AS Correlation_Coefficient
FROM CorrelationData;

-- 17. Are there patterns in downtime based on the time of day?
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
    FROM [Line productivity]
    WHERE Batch_duration_time IS NOT NULL
)
SELECT 
    sd.Shift,
    sum(lds.downtime_minutes) as downtimeMin
FROM ShiftedData sd
join Line_downtime_structured lds on sd.Batch = lds.BatchID
GROUP BY Shift
ORDER BY Shift;

--18. What is the overall efficiency of the manufacturing line (productive time vs. downtime)?
/* wrong query 
select 
	sum(lp.Batch_duration_time) as totalProductionTime,
	sum(lds.downtime_minutes) as totalDowntime,
	round((sum(lp.Batch_duration_time)-sum(lds.downtime_minutes))*100/(sum(lp.Batch_duration_time)),2) as 'Efficiency (%)'
from Line_downtime_structured lds
join [Line productivity] lp on lp.Batch = lds.BatchID
*/

SELECT 
    SUM(agg_prod.BatchDuration) AS totalProductionTime,
    SUM(agg_downtime.totalDowntime) AS totalDowntime,
    ROUND((SUM(agg_prod.BatchDuration) - SUM(agg_downtime.totalDowntime)) * 100 / 
          NULLIF(SUM(agg_prod.BatchDuration), 0), 2) AS "Efficiency (%)"
FROM 
    (SELECT Batch, SUM(Batch_duration_time) AS BatchDuration
     FROM [Line productivity]
     GROUP BY Batch) agg_prod
LEFT JOIN 
    (SELECT BatchID, SUM(downtime_minutes) AS totalDowntime
     FROM Line_downtime_structured
     GROUP BY BatchID) agg_downtime
ON agg_prod.Batch = agg_downtime.BatchID;