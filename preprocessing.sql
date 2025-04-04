-- Checking Missing Values for each Table
-- Line productivity table    
   select *
   FROM [dbo].[Line productivity]
   where Batch is null or Date is null or Product is null or [Start Time] is null or [End Time] is null or Operator is null
-- products table
   select
	sum(case when product is null then 1 else 0 end) as missing_prod,
	sum(case when flavor is null then 1 else 0 end) as missing_flav,
	sum(case when size is null then 1 else 0 end) as missing_size
	   FROM Products

   FROM [dbo].['Downtime_factors']
   where Factor is null or Description is null or [Operator Error] is null 

-- Line downtime table
select 
    sum(case when Batch is null then 1 else 0 end) as Batch, 
    sum(case when [1] is null then 1 else 0 end) as Factor_1, 
    sum(case when [2] is null then 1 else 0 end) as Factor_2,
	sum(case when [3] is null then 1 else 0 end) as Factor_3,
	sum(case when [4] is null then 1 else 0 end) as Factor_4,
	sum(case when [5] is null then 1 else 0 end) as Factor_5,
-- Donwtime factors table
 select *
	sum(case when [6] is null then 1 else 0 end) as Factor_6,
	sum(case when [7] is null then 1 else 0 end) as Factor_7,
	sum(case when [8] is null then 1 else 0 end) as Factor_8,
	sum(case when [9] is null then 1 else 0 end) as Factor_9,
	sum(case when [10] is null then 1 else 0 end) as Factor_10,
	sum(case when [11] is null then 1 else 0 end) as Factor_11,
	sum(case when [12] is null then 1 else 0 end) as Factor_12
from ['Line_downtime]


select * from [Line downtime] 

--create a new table to fill it with the structured data from the line_downtime table
Create table Line_downtime_structured (
	BatchID float,
	Downtime_factor float,
	downtime_minutes float
)
select * from [Line_downtime_structured]

select * from [Line downtime] where Batch is null

--insert the data from the Line_downtime table into the new table
INSERT INTO Line_downtime_structured (BatchID, Downtime_Factor, downtime_minutes)
SELECT [Batch], Downtime_Factor, Downtime_minutes
FROM (
    SELECT  [Batch],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
    FROM [Line downtime] 
) AS SourceTable
UNPIVOT (
    downtime_minutes FOR Downtime_Factor IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS UnpivotedTable;
 
 select * from Line_downtime_structured
 select F7 from [Line productivity]
 Alter table [Line productivity]
 drop column F7
 select * from [Downtime factors]

 -- prepare the dataset to build the data model
-- add the primary key and foreign key
 Alter table [Line productivity]
  alter column Batch float not null

Alter table [Line productivity]
add foreign key (product) references products(product)
add primary key (Batch)

Alter table products
alter column product nvarchar(255) not null

Alter table products
add primary key (product)

Alter table [downtime factors]
alter column factor float not null

Alter table [downtime factors]
add primary key (factor)

Alter table Line_downtime_structured
--add foreign key (BatchID) references dbo.[Line productivity](Batch)
add foreign key (Downtime_factor) references dbo.[Downtime factors](factor)

alter table [Line productivity]
add Batch_duration_time int

-- Convert Time to Proper time format
UPDATE [Line productivity]
SET [Start Time] = TRY_CAST([Start Time] AS TIME),
    [End Time] = TRY_CAST([End Time] AS TIME)
WHERE ISDATE([Start Time]) = 1 
      AND ISDATE([End Time]) = 1 
      AND TRY_CAST([Start Time] AS TIME) IS NOT NULL 
      AND TRY_CAST([End Time] AS TIME) IS NOT NULL;

Alter table [Line productivity]
--alter column [Start Time] time(0)
alter column [End Time] time(0)
--alter column [Date] date

-- adding the duration time to each batch
with timedifference as (
	select [Start Time], [End Time],
		CASE 
			WHEN [End Time] < [Start Time] 
			THEN DATEADD(SECOND, DATEDIFF(SECOND, [Start Time], DATEADD(HOUR, 24, [End Time])), '00:00:00')
			ELSE DATEADD(SECOND, DATEDIFF(SECOND, [Start Time], [End Time]), '00:00:00')
		END As duration
	from [Line productivity]
)
update lp
set Batch_duration_time = 
(DATEPART (HOUR, td.duration) *60) + (DATEPART(minute, td.duration)) 
from [Line productivity] lp
join timedifference td on lp.[Start Time] = td.[Start Time] and lp.[End Time] = td.[End Time]

--MODIFY Operator Error BOOLEAN;

UPDATE [Downtime factors]
SET [Operator Error] = 
    CASE 
        WHEN [Operator Error] = 'Yes' THEN 1 
        WHEN [Operator Error] = 'No' THEN 0 
    END
WHERE [Operator Error] IN ('Yes', 'No');