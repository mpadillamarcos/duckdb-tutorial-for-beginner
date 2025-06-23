-- https://www.youtube.com/watch?v=ZX5FdqzGT1E&ab_channel=MotherDuck

-- To read the dataset
SELECT * FROM read_csv_auto('./data/netflix_daily_top_10.csv') limit 3;
show tables; --empty

-- To create a table in the dataset
CREATE TABLE netflix_daily_top_10 AS FROM read_csv_auto('./data/netflix_daily_top_10.csv');

-- The data will be shown in mode 'duckbox'. It's the default one:
--  As of    │ Rank  │ Year to Date Rank │ Last Week Rank │ … │ Netflix Release Date │ Days In Top 10 │ Viewership Score │
-- │    date    │ int64 │      varchar      │    varchar     │   │       varchar        │     int64      │      int64       │
-- ├────────────┼───────┼───────────────────┼────────────────┼───┼──────────────────────┼────────────────┼──────────────────┤
-- │ 2020-04-01 │     1 │ 1                 │ 1              │ … │ Mar 20, 2020         │              9 │               90 │
-- │ 2020-04-01 │     2 │ 2                 │ -              │ … │ Jul 21, 2017         │              5 │               45 
.mode duckbox

-- This mode will print all the information for each line:
--                As of = 2022-03-02
--                 Rank = 9
--    Year to Date Rank = 6
--       Last Week Rank = 3
--                Title = Sweet Magnolias
--                 Type = TV Show
--    Netflix Exclusive = true
-- Netflix Release Date = May 19, 2020
--       Days In Top 10 = 45
--     Viewership Score = 344
.mode line

-- Self explanatory
.mode markdown
-- | 2022-01-20 | 5    | 4                 | -              | Brazen                         | Movie           | true              | Jan 13, 2022         | 7              | 55               |
-- | 2022-01-20 | 6    | 5                 | 2              | Cobra Kai                      | TV Show         | NULL              | Aug 28, 2020         | 73             | 546              |

FROM netflix_daily_top_10;

-- We can also save it as markdown
.output netflix_daily.md
FROM netflix_daily_top_10;

-- To see the default extensions
FROM duckdb_extensions();
-- To install an extension that is already available in the list shown above:
INSTALL httpfs;
LOAD httpfs;

SET s3_region='eu-south-2';
CREATE TABLE netflix AS SELECT * FROM read_parquet('s3://us-prd-motherduck-open-datasets/netflix/netflix_daily_top_10.parquet');
FROM netflix;
SHOW netflix;

-- Top 5 shows with most days in top 10
SELECT Title, max("Days In Top 10") FROM netflix
WHERE Type='TV Show'
GROUP BY Title
ORDER BY max("Days In Top 10") desc
limit 5;

-- Top 5 movies
SELECT Title, max("Days In Top 10") FROM netflix
WHERE Type='Movie'
GROUP BY Title
ORDER BY max("Days In Top 10") desc
limit 5;

-- Export the data to a csv file
COPY (
SELECT Title, max("Days In Top 10") AS 'Max Top 10' from netflix
where Type='TV Show'
GROUP BY Title
ORDER BY max("Days In Top 10") desc
limit 5
) TO 'output.csv' (HEADER, DELIMITER ',');