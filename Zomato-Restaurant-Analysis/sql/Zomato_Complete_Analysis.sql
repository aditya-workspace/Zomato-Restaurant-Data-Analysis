/*
===============================================================================
ZOMATO RESTAURANT ANALYTICS PROJECT
SQL Server Script | Database: ZomatoDB
Source table: dbo.Zomato_Raw

CONTENTS
  01. Create and populate dbo.Zomato_Cleaned
  02. Validate cleaned data
  03. Normalize restaurant-cuisine relationships
  04. Cuisine-level analysis
  05. City-level KPIs
  06. Delivery performance categories
  07. Restaurant performance categories
  08. Restaurant ranking within each city
  09. Top 3 restaurants per city
  10. Restaurant rating vs. city average
  11. City ranking by average rating
  12. City ranking by delivery performance
  13. Rolling 5-restaurant average
  14. Cumulative city average
  15. Restaurant performance score
  16. Final city KPI table
  17. Verification and result previews

IMPORTANT
  This script uses DROP TABLE IF EXISTS for derived tables and
  dbo.Zomato_Cleaned. It rebuilds those tables from dbo.Zomato_Raw.
  It does not drop dbo.Zomato_Raw.

Formatting pass only: SQL logic and calculations are preserved.
===============================================================================
*/

USE [ZomatoDB];
GO

/* 1. CLEANED TABLE */
DROP TABLE IF EXISTS dbo.Zomato_Cleaned;
GO

CREATE TABLE dbo.Zomato_Cleaned
(
    RestaurantID INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_name NVARCHAR(255) NULL,
    rating DECIMAL(3,2) NULL,
    cuisine NVARCHAR(MAX) NULL,
    average_price DECIMAL(10,2) NULL,
    delivery_time INT NULL,
    safety_measure NVARCHAR(MAX) NULL,
    safety_category NVARCHAR(50) NOT NULL,
    city NVARCHAR(100) NULL
);
GO

INSERT INTO dbo.Zomato_Cleaned
(restaurant_name, rating, cuisine, average_price, delivery_time,
 safety_measure, safety_category, city)
SELECT
    NULLIF(TRIM([Restaurant Name]), ''),
    CASE
        WHEN TRY_CONVERT(DECIMAL(3,2), NULLIF(TRIM([Rating]), '')) BETWEEN 0 AND 5
        THEN TRY_CONVERT(DECIMAL(3,2), NULLIF(TRIM([Rating]), ''))
        ELSE NULL
    END,
    NULLIF(TRIM([Cuisine]), ''),
    TRY_CONVERT(DECIMAL(10,2),
        NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(
            LOWER(TRIM([Average Price])), N'₹', N''), 'for one', ''), ',', ''), ' ', ''), '')
    ),
    TRY_CONVERT(INT,
        NULLIF(REPLACE(REPLACE(REPLACE(
            LOWER(TRIM([Average Delivery Time])), 'minutes', ''), 'mins', ''), 'min', ''), '')
    ),
    NULLIF(TRIM([Safety Measure]), ''),
    CASE
        WHEN [Safety Measure] IS NULL OR TRIM([Safety Measure]) = '' THEN 'Unknown'
        WHEN LOWER([Safety Measure]) LIKE '%max safety%'
          OR LOWER([Safety Measure]) LIKE '%who%' THEN 'High Safety'
        ELSE 'Standard Safety'
    END,
    NULLIF(TRIM([Location]), '')
FROM dbo.Zomato_Raw;
GO

/* Cleaned data checks */
SELECT
    COUNT(*) AS cleaned_rows,
    COUNT(DISTINCT city) AS distinct_cities,
    COUNT(DISTINCT restaurant_name) AS distinct_restaurant_names,
    COUNT(rating) AS rows_with_rating,
    COUNT(average_price) AS rows_with_price,
    COUNT(delivery_time) AS rows_with_delivery_time
FROM dbo.Zomato_Cleaned;
GO

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS missing_restaurant_name,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_or_invalid_rating,
    SUM(CASE WHEN cuisine IS NULL THEN 1 ELSE 0 END) AS missing_cuisine,
    SUM(CASE WHEN average_price IS NULL THEN 1 ELSE 0 END) AS missing_or_unconverted_price,
    SUM(CASE WHEN delivery_time IS NULL THEN 1 ELSE 0 END) AS missing_or_unconverted_delivery_time,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_city
FROM dbo.Zomato_Cleaned;
GO

SELECT safety_category, COUNT(*) AS restaurant_records
FROM dbo.Zomato_Cleaned
GROUP BY safety_category
ORDER BY restaurant_records DESC;
GO

/* 2. NORMALIZED CUISINE TABLE: one row per restaurant-cuisine */
DROP TABLE IF EXISTS dbo.RestaurantCuisine;
GO

SELECT
    z.RestaurantID,
    z.restaurant_name,
    z.city,
    z.rating,
    z.average_price,
    z.delivery_time,
    TRIM(s.value) AS cuisine
INTO dbo.RestaurantCuisine
FROM dbo.Zomato_Cleaned AS z
CROSS APPLY STRING_SPLIT(z.cuisine, ',') AS s
WHERE NULLIF(TRIM(s.value), '') IS NOT NULL;
GO

/* 3. CUISINE-LEVEL ANALYSIS */
DROP TABLE IF EXISTS dbo.Analysis_Cuisine;
GO

SELECT
    cuisine,
    COUNT(DISTINCT RestaurantID) AS RestaurantCount,
    ROUND(AVG(CAST(rating AS DECIMAL(10,2))), 2) AS AverageRating,
    ROUND(AVG(average_price), 2) AS AveragePrice,
    ROUND(AVG(CAST(delivery_time AS DECIMAL(10,2))), 2) AS AverageDeliveryTime,
    COUNT(DISTINCT CASE WHEN rating >= 4.0 THEN RestaurantID END) AS HighlyRatedRestaurants
INTO dbo.Analysis_Cuisine
FROM dbo.RestaurantCuisine
GROUP BY cuisine;
GO

/* 4. CITY-LEVEL KPIs */
DROP TABLE IF EXISTS dbo.Analysis_CityKPI;
GO

SELECT
    city,
    COUNT(*) AS TotalRestaurantRecords,
    COUNT(rating) AS RatedRestaurantRecords,
    ROUND(AVG(rating), 2) AS AverageRating,
    ROUND(AVG(average_price), 2) AS AveragePrice,
    ROUND(AVG(CAST(delivery_time AS DECIMAL(10,2))), 2) AS AverageDeliveryTime,
    SUM(CASE WHEN rating >= 4.0 THEN 1 ELSE 0 END) AS HighlyRatedRestaurants,
    SUM(CASE WHEN delivery_time <= 30 THEN 1 ELSE 0 END) AS FastDeliveryRestaurants,
    SUM(CASE WHEN safety_category = 'High Safety' THEN 1 ELSE 0 END) AS HighSafetyRestaurants
INTO dbo.Analysis_CityKPI
FROM dbo.Zomato_Cleaned
WHERE city IS NOT NULL
GROUP BY city;
GO

/* 5. DELIVERY PERFORMANCE CATEGORIES */
DROP TABLE IF EXISTS dbo.Analysis_Delivery;
GO

SELECT
    CASE
        WHEN delivery_time <= 20 THEN 'Very Fast'
        WHEN delivery_time <= 30 THEN 'Fast'
        WHEN delivery_time <= 45 THEN 'Moderate'
        WHEN delivery_time <= 60 THEN 'Slow'
        ELSE 'Very Slow'
    END AS DeliveryCategory,
    COUNT(*) AS RestaurantCount,
    ROUND(AVG(rating), 2) AS AverageRating,
    ROUND(AVG(average_price), 2) AS AveragePrice,
    ROUND(AVG(CAST(delivery_time AS DECIMAL(10,2))), 2) AS AverageDeliveryTime
INTO dbo.Analysis_Delivery
FROM dbo.Zomato_Cleaned
WHERE delivery_time IS NOT NULL
GROUP BY
    CASE
        WHEN delivery_time <= 20 THEN 'Very Fast'
        WHEN delivery_time <= 30 THEN 'Fast'
        WHEN delivery_time <= 45 THEN 'Moderate'
        WHEN delivery_time <= 60 THEN 'Slow'
        ELSE 'Very Slow'
    END;
GO

/* 6. RESTAURANT PERFORMANCE CATEGORIES */
DROP TABLE IF EXISTS dbo.Analysis_RestaurantPerformance;
GO

SELECT
    RestaurantID, restaurant_name, city, rating, average_price, delivery_time, safety_category,
    CASE
        WHEN rating IS NULL THEN 'Not Rated'
        WHEN rating >= 4.5 THEN 'Excellent'
        WHEN rating >= 4.0 THEN 'Very Good'
        WHEN rating >= 3.5 THEN 'Good'
        WHEN rating >= 3.0 THEN 'Average'
        ELSE 'Below Average'
    END AS RatingCategory,
    CASE
        WHEN delivery_time IS NULL THEN 'Unknown'
        WHEN delivery_time <= 20 THEN 'Very Fast'
        WHEN delivery_time <= 30 THEN 'Fast'
        WHEN delivery_time <= 45 THEN 'Moderate'
        WHEN delivery_time <= 60 THEN 'Slow'
        ELSE 'Very Slow'
    END AS DeliveryCategory
INTO dbo.Analysis_RestaurantPerformance
FROM dbo.Zomato_Cleaned;
GO

/* 7. RESTAURANT RANK WITHIN EACH CITY */
DROP TABLE IF EXISTS dbo.Analysis_RestaurantRanking;
GO

SELECT
    RestaurantID, restaurant_name, city, rating, average_price, delivery_time,
    RANK() OVER (PARTITION BY city ORDER BY rating DESC, delivery_time ASC) AS CityRank
INTO dbo.Analysis_RestaurantRanking
FROM dbo.Zomato_Cleaned
WHERE rating IS NOT NULL AND city IS NOT NULL;
GO

/* 8. TOP 3 RESTAURANTS PER CITY */
DROP TABLE IF EXISTS dbo.Analysis_Top3City;
GO

WITH RankedRestaurants AS
(
    SELECT
        RestaurantID, restaurant_name, city, rating, average_price, delivery_time,
        ROW_NUMBER() OVER
        (PARTITION BY city ORDER BY rating DESC, delivery_time ASC, RestaurantID) AS CityRank
    FROM dbo.Zomato_Cleaned
    WHERE rating IS NOT NULL AND city IS NOT NULL
)
SELECT *
INTO dbo.Analysis_Top3City
FROM RankedRestaurants
WHERE CityRank <= 3;
GO

/* 9. RESTAURANT RATING VS CITY AVERAGE */
DROP TABLE IF EXISTS dbo.Analysis_CityComparison;
GO

WITH CityAverage AS
(
    SELECT city, AVG(rating) AS CityAverageRating
    FROM dbo.Zomato_Cleaned
    WHERE rating IS NOT NULL AND city IS NOT NULL
    GROUP BY city
)
SELECT
    z.RestaurantID, z.restaurant_name, z.city, z.rating,
    ROUND(c.CityAverageRating, 2) AS CityAverageRating,
    ROUND(z.rating - c.CityAverageRating, 2) AS DifferenceFromCityAverage,
    CASE
        WHEN z.rating > c.CityAverageRating THEN 'Above City Average'
        WHEN z.rating < c.CityAverageRating THEN 'Below City Average'
        ELSE 'Equal to City Average'
    END AS RatingVsCityAverage
INTO dbo.Analysis_CityComparison
FROM dbo.Zomato_Cleaned AS z
JOIN CityAverage AS c ON z.city = c.city
WHERE z.rating IS NOT NULL;
GO

/* 10. CITY RANK BY AVERAGE RATING */
DROP TABLE IF EXISTS dbo.Analysis_CityRatingRank;
GO

WITH CityKPIs AS
(
    SELECT
        city, COUNT(*) AS RestaurantCount, AVG(rating) AS AverageRating,
        AVG(average_price) AS AveragePrice,
        AVG(CAST(delivery_time AS DECIMAL(10,2))) AS AverageDeliveryTime
    FROM dbo.Zomato_Cleaned
    WHERE city IS NOT NULL
    GROUP BY city
)
SELECT
    city, RestaurantCount,
    ROUND(AverageRating, 2) AS AverageRating,
    ROUND(AveragePrice, 2) AS AveragePrice,
    ROUND(AverageDeliveryTime, 2) AS AverageDeliveryTime,
    DENSE_RANK() OVER (ORDER BY AverageRating DESC) AS CityRatingRank
INTO dbo.Analysis_CityRatingRank
FROM CityKPIs;
GO

/* 11. CITY RANK BY DELIVERY PERFORMANCE (lower is better) */
DROP TABLE IF EXISTS dbo.Analysis_CityDeliveryRank;
GO

WITH CityKPIs AS
(
    SELECT
        city, COUNT(*) AS RestaurantCount, AVG(rating) AS AverageRating,
        AVG(CAST(delivery_time AS DECIMAL(10,2))) AS AverageDeliveryTime
    FROM dbo.Zomato_Cleaned
    WHERE city IS NOT NULL AND delivery_time IS NOT NULL
    GROUP BY city
)
SELECT
    city, RestaurantCount,
    ROUND(AverageRating, 2) AS AverageRating,
    ROUND(AverageDeliveryTime, 2) AS AverageDeliveryTime,
    RANK() OVER (ORDER BY AverageDeliveryTime ASC) AS DeliveryRank
INTO dbo.Analysis_CityDeliveryRank
FROM CityKPIs;
GO

/* 12. ROLLING 5-RESTAURANT AVERAGE
   This is ordered by rating rank, not time; the source has no date column. */
DROP TABLE IF EXISTS dbo.Analysis_Rolling;
GO

WITH RankedRestaurants AS
(
    SELECT
        RestaurantID, restaurant_name, city, rating,
        ROW_NUMBER() OVER
        (PARTITION BY city ORDER BY rating DESC, RestaurantID) AS RestaurantRank
    FROM dbo.Zomato_Cleaned
    WHERE rating IS NOT NULL AND city IS NOT NULL
)
SELECT
    RestaurantID, restaurant_name, city, rating, RestaurantRank,
    ROUND(AVG(CAST(rating AS DECIMAL(10,2))) OVER
    (
        PARTITION BY city ORDER BY RestaurantRank
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling5RestaurantAverage
INTO dbo.Analysis_Rolling
FROM RankedRestaurants;
GO

/* 13. CUMULATIVE CITY AVERAGE */
DROP TABLE IF EXISTS dbo.Analysis_Cumulative;
GO

WITH RankedRestaurants AS
(
    SELECT
        RestaurantID, restaurant_name, city, rating,
        ROW_NUMBER() OVER
        (PARTITION BY city ORDER BY rating DESC, RestaurantID) AS RestaurantRank
    FROM dbo.Zomato_Cleaned
    WHERE rating IS NOT NULL AND city IS NOT NULL
)
SELECT
    RestaurantID, restaurant_name, city, rating, RestaurantRank,
    ROUND(AVG(CAST(rating AS DECIMAL(10,2))) OVER
    (
        PARTITION BY city ORDER BY RestaurantRank
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS CumulativeAverageRating
INTO dbo.Analysis_Cumulative
FROM RankedRestaurants;
GO

/* 14. OVERALL RESTAURANT PERFORMANCE SCORE
   Rating = 60%; delivery speed = 40%.
   A score is not calculated when rating or delivery is missing. */
DROP TABLE IF EXISTS dbo.Analysis_PerformanceScore;
GO

WITH Base AS
(
    SELECT
        RestaurantID, restaurant_name, city, rating, average_price, delivery_time,
        MAX(CAST(delivery_time AS DECIMAL(10,2))) OVER () AS MaxDeliveryTime
    FROM dbo.Zomato_Cleaned
)
SELECT
    RestaurantID, restaurant_name, city, rating, average_price, delivery_time,
    CAST(ROUND(
        (rating / 5.0 * 60.0)
        + ((1.0 - delivery_time / NULLIF(MaxDeliveryTime, 0)) * 40.0), 2
    ) AS DECIMAL(5,2)) AS PerformanceScore,
    CASE
        WHEN rating IS NULL OR delivery_time IS NULL THEN 'Insufficient Data'
        WHEN (rating / 5.0 * 60.0)
             + ((1.0 - delivery_time / NULLIF(MaxDeliveryTime, 0)) * 40.0) >= 80
            THEN 'Excellent'
        WHEN (rating / 5.0 * 60.0)
             + ((1.0 - delivery_time / NULLIF(MaxDeliveryTime, 0)) * 40.0) >= 65
            THEN 'Good'
        WHEN (rating / 5.0 * 60.0)
             + ((1.0 - delivery_time / NULLIF(MaxDeliveryTime, 0)) * 40.0) >= 50
            THEN 'Average'
        ELSE 'Needs Improvement'
    END AS PerformanceCategory
INTO dbo.Analysis_PerformanceScore
FROM Base;
GO

/* 15. FINAL CITY KPI TABLE */
DROP TABLE IF EXISTS dbo.Analysis_FinalKPI;
GO

WITH CityKPIs AS
(
    SELECT
        city,
        COUNT(*) AS TotalRestaurants,
        COUNT(rating) AS RatedRestaurants,
        AVG(rating) AS AverageRating,
        AVG(average_price) AS AveragePrice,
        AVG(CAST(delivery_time AS DECIMAL(10,2))) AS AverageDeliveryTime,
        SUM(CASE WHEN rating >= 4.0 THEN 1 ELSE 0 END) AS HighlyRatedRestaurants,
        SUM(CASE WHEN delivery_time <= 30 THEN 1 ELSE 0 END) AS FastDeliveryRestaurants,
        SUM(CASE WHEN safety_category = 'High Safety' THEN 1 ELSE 0 END) AS HighSafetyRestaurants
    FROM dbo.Zomato_Cleaned
    WHERE city IS NOT NULL
    GROUP BY city
),
ScoredCities AS
(
    SELECT *,
        CASE
            WHEN AverageRating IS NULL OR AverageDeliveryTime IS NULL THEN NULL
            ELSE (AverageRating / 5.0 * 60.0)
                 + ((1.0 - AverageDeliveryTime /
                    NULLIF(MAX(AverageDeliveryTime) OVER (), 0)) * 40.0)
        END AS CityPerformanceScore
    FROM CityKPIs
)
SELECT
    city, TotalRestaurants, RatedRestaurants,
    ROUND(AverageRating, 2) AS AverageRating,
    ROUND(AveragePrice, 2) AS AveragePrice,
    ROUND(AverageDeliveryTime, 2) AS AverageDeliveryTime,
    HighlyRatedRestaurants,
    ROUND(100.0 * HighlyRatedRestaurants / NULLIF(RatedRestaurants, 0), 2) AS HighRatingPercentage,
    FastDeliveryRestaurants,
    ROUND(100.0 * FastDeliveryRestaurants / NULLIF(TotalRestaurants, 0), 2) AS FastDeliveryPercentage,
    HighSafetyRestaurants,
    ROUND(100.0 * HighSafetyRestaurants / NULLIF(TotalRestaurants, 0), 2) AS HighSafetyPercentage,
    ROUND(CityPerformanceScore, 2) AS CityPerformanceScore,
    DENSE_RANK() OVER (ORDER BY AverageRating DESC) AS RatingRank,
    DENSE_RANK() OVER (ORDER BY AverageDeliveryTime ASC) AS DeliveryRank,
    DENSE_RANK() OVER (ORDER BY CityPerformanceScore DESC) AS OverallCityRank
INTO dbo.Analysis_FinalKPI
FROM ScoredCities;
GO

/* 16. VERIFICATION */
SELECT
    (SELECT COUNT(*) FROM dbo.Zomato_Raw) AS RawRows,
    (SELECT COUNT(*) FROM dbo.Zomato_Cleaned) AS CleanedRows;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND (TABLE_NAME IN ('Zomato_Raw', 'Zomato_Cleaned', 'RestaurantCuisine')
       OR TABLE_NAME LIKE 'Analysis_%')
ORDER BY TABLE_NAME;
GO

SELECT 'Zomato_Raw' AS TableName, COUNT(*) AS TotalRows FROM dbo.Zomato_Raw
UNION ALL SELECT 'Zomato_Cleaned', COUNT(*) FROM dbo.Zomato_Cleaned
UNION ALL SELECT 'RestaurantCuisine', COUNT(*) FROM dbo.RestaurantCuisine
UNION ALL SELECT 'Analysis_Cuisine', COUNT(*) FROM dbo.Analysis_Cuisine
UNION ALL SELECT 'Analysis_CityKPI', COUNT(*) FROM dbo.Analysis_CityKPI
UNION ALL SELECT 'Analysis_Delivery', COUNT(*) FROM dbo.Analysis_Delivery
UNION ALL SELECT 'Analysis_RestaurantPerformance', COUNT(*) FROM dbo.Analysis_RestaurantPerformance
UNION ALL SELECT 'Analysis_RestaurantRanking', COUNT(*) FROM dbo.Analysis_RestaurantRanking
UNION ALL SELECT 'Analysis_Top3City', COUNT(*) FROM dbo.Analysis_Top3City
UNION ALL SELECT 'Analysis_CityComparison', COUNT(*) FROM dbo.Analysis_CityComparison
UNION ALL SELECT 'Analysis_CityRatingRank', COUNT(*) FROM dbo.Analysis_CityRatingRank
UNION ALL SELECT 'Analysis_CityDeliveryRank', COUNT(*) FROM dbo.Analysis_CityDeliveryRank
UNION ALL SELECT 'Analysis_Rolling', COUNT(*) FROM dbo.Analysis_Rolling
UNION ALL SELECT 'Analysis_Cumulative', COUNT(*) FROM dbo.Analysis_Cumulative
UNION ALL SELECT 'Analysis_PerformanceScore', COUNT(*) FROM dbo.Analysis_PerformanceScore
UNION ALL SELECT 'Analysis_FinalKPI', COUNT(*) FROM dbo.Analysis_FinalKPI
ORDER BY TableName;
GO

SELECT * FROM dbo.Analysis_FinalKPI ORDER BY OverallCityRank;
GO

SELECT * FROM dbo.Analysis_Top3City ORDER BY city, CityRank;
GO
