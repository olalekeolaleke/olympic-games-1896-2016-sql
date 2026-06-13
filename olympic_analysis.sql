-- =============================================
-- Project     : Olympic Games Historical Analysis (1896 - 2016)
-- Database    : PortfolioProject
-- Author      : Olaleke Sangogade
-- Date        : May 2026
-- Description : End-to-end SQL analysis of 120 years of Olympic Games data
--               covering athlete demographics, country performance, sport trends,
--               and medal breakdowns using SQL Server.
-- =============================================


-- 1. Database Setup

CREATE DATABASE PortfolioProject;
GO

USE PortfolioProject;
GO


-- =============================================
-- Phase 1 - Database Setup and Exploration
-- =============================================


-- Task 1: Create tables and load data

-- Table 1: country_definition

DROP TABLE IF EXISTS country_definition;

CREATE TABLE country_definition (
    NOC    VARCHAR(10),
    region VARCHAR(100),
    notes  VARCHAR(255)
);

BULK INSERT country_definition
FROM '/var/opt/mssql/country_fixed.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    KEEPNULLS
);

-- Table 2: athlete_events

DROP TABLE IF EXISTS athlete_events;

CREATE TABLE athlete_events (
    ID     VARCHAR(50),
    Name   VARCHAR(255),
    Sex    VARCHAR(10),
    Age    VARCHAR(50),
    Height VARCHAR(50),
    Weight VARCHAR(50),
    Team   VARCHAR(255),
    NOC    VARCHAR(50),
    Games  VARCHAR(50),
    Year   VARCHAR(50),
    Season VARCHAR(50),
    City   VARCHAR(100),
    Sport  VARCHAR(100),
    Event  VARCHAR(255),
    Medal  VARCHAR(50)
);
GO

BULK INSERT athlete_events
FROM '/var/opt/mssql/athlete_events.csv'
WITH (
    FORMAT      = 'CSV',
    FIRSTROW    = 2,
    FIELDQUOTE  = '"',
    ROWTERMINATOR = '\n'
);
GO


-- Task 2: Verify row counts and join

SELECT COUNT(*) AS country_definition_rows FROM country_definition;   -- 230
SELECT COUNT(*) AS athlete_events_rows      FROM athlete_events;       -- 271116

SELECT TOP 5
    ae.Name,
    ae.Sport,
    ae.Medal,
    cd.region
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC;


-- Task 3: Inspect table structure

-- Column data types - country_definition
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'country_definition';

-- Column data types - athlete_events
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'athlete_events';

-- NULL counts - athlete_events
SELECT
    SUM(CASE WHEN ID     IS NULL THEN 1 ELSE 0 END) AS Null_ID,
    SUM(CASE WHEN Name   IS NULL THEN 1 ELSE 0 END) AS Null_Name,
    SUM(CASE WHEN Sex    IS NULL THEN 1 ELSE 0 END) AS Null_Sex,
    SUM(CASE WHEN Age    IS NULL THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN Height IS NULL THEN 1 ELSE 0 END) AS Null_Height,
    SUM(CASE WHEN Weight IS NULL THEN 1 ELSE 0 END) AS Null_Weight,
    SUM(CASE WHEN Team   IS NULL THEN 1 ELSE 0 END) AS Null_Team,
    SUM(CASE WHEN NOC    IS NULL THEN 1 ELSE 0 END) AS Null_NOC,
    SUM(CASE WHEN Games  IS NULL THEN 1 ELSE 0 END) AS Null_Games,
    SUM(CASE WHEN Year   IS NULL THEN 1 ELSE 0 END) AS Null_Year,
    SUM(CASE WHEN Season IS NULL THEN 1 ELSE 0 END) AS Null_Season,
    SUM(CASE WHEN City   IS NULL THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN Sport  IS NULL THEN 1 ELSE 0 END) AS Null_Sport,
    SUM(CASE WHEN Event  IS NULL THEN 1 ELSE 0 END) AS Null_Event,
    SUM(CASE WHEN Medal  IS NULL THEN 1 ELSE 0 END) AS Null_Medal
FROM athlete_events;

-- NULL counts - country_definition
SELECT
    SUM(CASE WHEN NOC    IS NULL THEN 1 ELSE 0 END) AS Null_NOC,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS Null_region,
    SUM(CASE WHEN notes  IS NULL THEN 1 ELSE 0 END) AS Null_notes
FROM country_definition;

-- Duplicate check - country_definition
SELECT NOC, COUNT(*) AS Count
FROM country_definition
GROUP BY NOC
HAVING COUNT(*) > 1;


-- Task 4: Identify unique values in key columns

SELECT DISTINCT Year  AS Unique_Years  FROM athlete_events ORDER BY Year;
SELECT DISTINCT Sport AS Unique_Sports FROM athlete_events ORDER BY Sport;
SELECT DISTINCT Event AS Unique_Events FROM athlete_events ORDER BY Event;

SELECT DISTINCT region AS Participating_Nations
FROM country_definition
ORDER BY region;


-- =============================================
-- Part 1: Exploratory Data Analysis
-- =============================================

-- 1. How many unique Olympic Games are recorded in the dataset?
SELECT COUNT(DISTINCT Games) AS Unique_Olympic_Games
FROM athlete_events;

-- 2. How many unique athletes, sports, and events exist?
SELECT
    COUNT(DISTINCT Name)  AS Unique_Athletes,
    COUNT(DISTINCT Sport) AS Unique_Sports,
    COUNT(DISTINCT Event) AS Unique_Events
FROM athlete_events;

-- 3. What is the breakdown of Summer vs Winter Games?
SELECT Season, COUNT(*) AS Total_Records
FROM athlete_events
GROUP BY Season;

-- 4. How many total medal-winning rows exist, and what is the split by medal type?
SELECT
    COUNT(*) AS Total_Medal_Records,
    SUM(CASE WHEN Medal = 'Gold'   THEN 1 ELSE 0 END) AS Gold_Count,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver_Count,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze_Count
FROM athlete_events
WHERE Medal IS NOT NULL;


-- =============================================
-- Part 2: Athlete Demographics
-- =============================================

-- 1. What is the average age, height, and weight of athletes across all Games?
SELECT
    ROUND(AVG(TRY_CAST(Age    AS FLOAT)), 2) AS Average_Age,
    ROUND(AVG(TRY_CAST(Height AS FLOAT)), 2) AS Average_Height,
    ROUND(AVG(TRY_CAST(Weight AS FLOAT)), 2) AS Average_Weight
FROM athlete_events
WHERE TRY_CAST(Age    AS FLOAT) IS NOT NULL
  AND TRY_CAST(Height AS FLOAT) IS NOT NULL
  AND TRY_CAST(Weight AS FLOAT) IS NOT NULL;

-- 2. What is the average age broken down by sex?
SELECT
    Sex,
    ROUND(AVG(CAST(Age AS FLOAT)), 2) AS Average_Age
FROM athlete_events
WHERE Age IS NOT NULL
GROUP BY Sex;

-- 3. Which sport has the oldest average athlete age?
SELECT TOP 1
    Sport,
    ROUND(AVG(CAST(Age AS FLOAT)), 2) AS Oldest_Average_Age
FROM athlete_events
WHERE Age IS NOT NULL
GROUP BY Sport
ORDER BY Oldest_Average_Age DESC;

-- Which sport has the youngest average athlete age?
SELECT TOP 1
    Sport,
    ROUND(AVG(CAST(Age AS FLOAT)), 2) AS Youngest_Average_Age
FROM athlete_events
WHERE Age IS NOT NULL
GROUP BY Sport
ORDER BY Youngest_Average_Age ASC;

-- 4. How has the average age of Olympic athletes changed over the years?
SELECT
    Year,
    ROUND(AVG(CAST(Age AS FLOAT)), 2) AS Average_Age
FROM athlete_events
WHERE Age IS NOT NULL
GROUP BY Year
ORDER BY Year;

-- 5. Which years have the highest percentage of missing Age, Height, and Weight data?
SELECT
    Year,
    SUM(CASE WHEN Age    IS NULL THEN 1 ELSE 0 END) AS Null_Age_Count,
    SUM(CASE WHEN Height IS NULL THEN 1 ELSE 0 END) AS Null_Height_Count,
    SUM(CASE WHEN Weight IS NULL THEN 1 ELSE 0 END) AS Null_Weight_Count,
    COUNT(*) AS Total_Entries,
    ROUND(100.0 * SUM(CASE WHEN Age    IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS Null_Age_Pct,
    ROUND(100.0 * SUM(CASE WHEN Height IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS Null_Height_Pct,
    ROUND(100.0 * SUM(CASE WHEN Weight IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS Null_Weight_Pct
FROM athlete_events
GROUP BY Year
ORDER BY Year;


-- =============================================
-- Part 3: Country Performance
-- =============================================

-- 1. Which 10 countries have won the most Gold medals all time?
SELECT TOP 10
    cd.region,
    COUNT(*) AS Gold_Medal_Count
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
WHERE ae.Medal = 'Gold'
GROUP BY cd.region
ORDER BY Gold_Medal_Count DESC;

-- 2. Which 10 countries have won the most total medals all time?
SELECT TOP 10
    cd.region,
    COUNT(*) AS Total_Medal_Count
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
WHERE ae.Medal IS NOT NULL
GROUP BY cd.region
ORDER BY Total_Medal_Count DESC;

-- 3. Which country has sent the most unique athletes across all Games?
SELECT TOP 1
    cd.region,
    COUNT(DISTINCT ae.Name) AS Unique_Athlete_Count
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
GROUP BY cd.region
ORDER BY Unique_Athlete_Count DESC;

-- 4. Which countries have never won a single medal?
SELECT cd.region
FROM country_definition cd
LEFT JOIN athlete_events ae
    ON cd.NOC = ae.NOC
    AND ae.Medal IS NOT NULL
WHERE ae.ID IS NULL
ORDER BY cd.region;

-- 5. What is the medal count per country per Olympic year?
SELECT
    cd.region,
    ae.Year,
    COUNT(*) AS Medal_Count
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
WHERE ae.Medal IS NOT NULL
GROUP BY cd.region, ae.Year
ORDER BY ae.Year, Medal_Count DESC;


-- =============================================
-- Part 4: Sport and Event Analysis
-- =============================================

-- 1. How many distinct sports and events are in the dataset?
SELECT
    COUNT(DISTINCT Sport) AS Distinct_Sports,
    COUNT(DISTINCT Event) AS Distinct_Events
FROM athlete_events;

-- 2. Which sports appear in every Summer Games?
SELECT Sport
FROM athlete_events
WHERE Season = 'Summer'
GROUP BY Sport
HAVING COUNT(DISTINCT Games) = (
    SELECT COUNT(DISTINCT Games)
    FROM athlete_events
    WHERE Season = 'Summer'
);

-- Which sports appear in every Winter Games?
SELECT Sport
FROM athlete_events
WHERE Season = 'Winter'
GROUP BY Sport
HAVING COUNT(DISTINCT Games) = (
    SELECT COUNT(DISTINCT Games)
    FROM athlete_events
    WHERE Season = 'Winter'
);

-- 3. Which sports only appeared once and were never seen again?
SELECT
    Sport,
    COUNT(DISTINCT Games) AS Appearance_Count
FROM athlete_events
GROUP BY Sport
HAVING COUNT(DISTINCT Games) = 1;

-- 4. Which event had the most athletes competing in a single Games?
SELECT TOP 1
    Games,
    Event,
    COUNT(DISTINCT Name) AS Athlete_Count
FROM athlete_events
GROUP BY Games, Event
ORDER BY Athlete_Count DESC;

-- 5. Which event produces the most total medals across all Games?
SELECT TOP 1
    Event,
    COUNT(*) AS Total_Medals
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY Event
ORDER BY Total_Medals DESC;


-- =============================================
-- Part 5: Medal Trends Over Time
-- =============================================

-- 1. How has the total number of medals awarded changed across Olympic years?
SELECT
    Year,
    Season,
    COUNT(*) AS Total_Medals
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY Year, Season
ORDER BY Year;

-- 2. How has female athlete participation grown year by year?
SELECT
    Year,
    COUNT(*) AS Total_Female_Athletes
FROM athlete_events
WHERE Sex = 'F'
GROUP BY Year
ORDER BY Year;

-- 3. Which year had the highest number of participating countries?
SELECT TOP 10
    Year,
    COUNT(DISTINCT NOC) AS Participating_Countries
FROM athlete_events
GROUP BY Year
ORDER BY Participating_Countries DESC;

-- 4. How many new countries made their Olympic debut each decade?
SELECT
    CAST(debut_decade AS VARCHAR) + 's' AS Decade,
    COUNT(*) AS New_Countries
FROM (
    SELECT
        NOC,
        (MIN(Year) / 10) * 10 AS debut_decade
    FROM athlete_events
    GROUP BY NOC
) AS debut_table
GROUP BY debut_decade
ORDER BY debut_decade;


-- =============================================
-- Part 6: Notable Athletes
-- =============================================

-- 1. Who are the top 10 most decorated athletes of all time?
SELECT TOP 10
    Name,
    COUNT(*) AS Total_Medals
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY Name
ORDER BY Total_Medals DESC;

-- 2. Who are the top 10 Gold medal winners of all time?
SELECT TOP 10
    Name,
    COUNT(*) AS Gold_Medal_Count
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
ORDER BY Gold_Medal_Count DESC;

-- 3. Who is the youngest Gold medallist ever recorded?
SELECT TOP 1 Name, Age
FROM athlete_events
WHERE Medal = 'Gold' AND Age IS NOT NULL
ORDER BY CAST(Age AS INT) ASC;

-- Who is the oldest Gold medallist ever recorded?
SELECT TOP 1 Name, Age
FROM athlete_events
WHERE Medal = 'Gold' AND Age IS NOT NULL
ORDER BY CAST(Age AS INT) DESC;

-- 4. Which athlete competed in the most Olympic Games?
SELECT TOP 1
    Name,
    COUNT(DISTINCT Games) AS Total_Games
FROM athlete_events
GROUP BY Name
ORDER BY Total_Games DESC;

-- 5. Which athletes won a medal in 3 or more different Olympic years?
SELECT
    Name,
    COUNT(DISTINCT Year) AS Years_With_Medals
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY Name
HAVING COUNT(DISTINCT Year) >= 3
ORDER BY Years_With_Medals DESC;


-- =============================================
-- Part 7: Advanced Window Functions
-- =============================================

-- 1. Rank countries by total medals within each Olympic year
SELECT
    Year,
    NOC,
    COUNT(*) AS Total_Medals,
    RANK() OVER (
        PARTITION BY Year
        ORDER BY COUNT(*) DESC
    ) AS Medal_Rank
FROM athlete_events
WHERE Medal IS NOT NULL
GROUP BY Year, NOC
ORDER BY Year, Medal_Rank;

-- 2. For each country, find the Olympic year they won the most medals (peak year)
SELECT r.Year, cd.region, r.Total_Medals
FROM (
    SELECT
        Year,
        NOC,
        COUNT(*) AS Total_Medals,
        RANK() OVER (
            PARTITION BY NOC
            ORDER BY COUNT(*) DESC
        ) AS Medal_Rank
    FROM athlete_events
    WHERE Medal IS NOT NULL
    GROUP BY Year, NOC
) AS r
JOIN country_definition cd ON r.NOC = cd.NOC
WHERE r.Medal_Rank = 1
ORDER BY r.Total_Medals DESC;

-- 3. Medal conversion rate per country - medals won vs athletes sent
SELECT
    cd.region,
    COUNT(DISTINCT ae.ID) AS Total_Athletes_Sent,
    SUM(CASE WHEN ae.Medal IS NOT NULL THEN 1 ELSE 0 END) AS Total_Medals_Won,
    ROUND(
        100.0 * SUM(CASE WHEN ae.Medal IS NOT NULL THEN 1 ELSE 0 END)
        / COUNT(DISTINCT ae.ID), 2
    ) AS Medal_Conversion_Pct
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
GROUP BY cd.region
ORDER BY Medal_Conversion_Pct DESC;

-- 4. Pivot showing Gold, Silver, and Bronze counts side by side per country
SELECT
    region,
    [Gold],
    [Silver],
    [Bronze],
    [Gold] + [Silver] + [Bronze] AS Total_Medals
FROM (
    SELECT cd.region, ae.Medal
    FROM athlete_events ae
    JOIN country_definition cd ON ae.NOC = cd.NOC
    WHERE ae.Medal IS NOT NULL
) AS medal_data
PIVOT (
    COUNT(Medal)
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS pivot_table
ORDER BY Total_Medals DESC;

-- 5. Find athletes who competed in consecutive Olympic Games using LAG()
SELECT DISTINCT
    Name,
    NOC,
    Year,
    prev_year,
    CAST(Year AS INT) - CAST(prev_year AS INT) AS Years_Apart
FROM (
    SELECT
        Name,
        NOC,
        Year,
        LAG(Year) OVER (
            PARTITION BY Name
            ORDER BY CAST(Year AS INT)
        ) AS prev_year
    FROM (
        SELECT DISTINCT Name, NOC, Year
        FROM athlete_events
    ) AS unique_appearances
) AS lagged
WHERE CAST(Year AS INT) - CAST(prev_year AS INT) IN (2, 4)
ORDER BY Name;


-- =============================================
-- Part 8: NOC and Region Data Quality
-- =============================================

-- 1. Which NOC codes in athlete_events have no match in country_definition?
SELECT DISTINCT ae.NOC
FROM athlete_events ae
LEFT JOIN country_definition cd ON ae.NOC = cd.NOC
WHERE cd.NOC IS NULL;

-- 2. Which region has the most NOC codes mapped to it?
SELECT TOP 1
    cd.region,
    COUNT(DISTINCT ae.NOC) AS NOC_Count
FROM athlete_events ae
JOIN country_definition cd ON ae.NOC = cd.NOC
GROUP BY cd.region
ORDER BY NOC_Count DESC;

-- 3. Which countries in country_definition never sent a single athlete?
SELECT cd.region
FROM country_definition cd
LEFT JOIN athlete_events ae ON cd.NOC = ae.NOC
WHERE ae.NOC IS NULL
ORDER BY cd.region;
