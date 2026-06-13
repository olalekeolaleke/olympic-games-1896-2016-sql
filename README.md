Olympic Games Historical Analysis (1896 - 2016)

Author: Olaleke Sangogade
Tool: SQL Server (run inside Docker on Mac)
Date: May 2026


Project Overview

This project explores 120 years of Olympic Games data using SQL Server.
The analysis covers athlete demographics, country medal performance, sport
and event trends, and participation growth over time. It progresses from
basic exploration through to advanced window functions and pivot tables.


Dataset

Two tables were used in this project.

athlete_events
271,116 rows. Each row represents one athlete competing in one event at
one Olympic Games. Columns include athlete ID, name, sex, age, height,
weight, team, NOC code, Games, year, season, city, sport, event, and medal.
Non-medal rows have a NULL value in the Medal column.

country_definition
230 rows. A lookup table mapping each three-letter NOC code to a country
or region name, with historical notes where applicable.

The two tables join on the NOC column.


Data Notes

Age, Height, and Weight contain NULL values, particularly for early Games
(pre-1960). These are handled throughout using IS NOT NULL filters and
TRY_CAST where appropriate.

Medal values are stored as Gold, Silver, Bronze, or NULL. NULL means the
athlete did not win a medal. All medal filters use IS NOT NULL rather than
string comparisons.

The Year column is stored as VARCHAR and is cast to INT where numeric
sorting or arithmetic is required.


Analysis Structure

Phase 1: Database Setup and Exploration
Table creation, bulk data loading, NULL profiling, duplicate checks,
and unique value identification across key columns.

Part 1: Exploratory Data Analysis
Unique Games count, athlete and event totals, Summer vs Winter breakdown,
and total medal distribution by type.

Part 2: Athlete Demographics
Average age, height, and weight across all Games. Age breakdown by sex.
Sports with oldest and youngest average athletes. Age trends over time.
NULL data quality profiling by year.

Part 3: Country Performance
Top 10 countries by Gold medals and total medals. Country with the most
unique athletes. Countries that never won a medal. Medal counts per country
per year as a running timeline.

Part 4: Sport and Event Analysis
Sports present in every Summer and Winter Games. Sports that appeared only
once. Most contested event by athlete count. Event with the most total medals.

Part 5: Medal Trends Over Time
Medal totals by year and season. Female athlete participation growth.
Top years by participating country count. Olympic debut counts by decade.

Part 6: Notable Athletes
Top 10 most decorated athletes overall and by Gold medals. Youngest and
oldest Gold medallists. Athlete with the most Games appearances. Athletes
who medalled across 3 or more Olympic years.

Part 7: Advanced Window Functions
Countries ranked by medals within each year using RANK(). Peak medal year
per country using a subquery and RANK(). Medal conversion rate per country.
PIVOT showing Gold, Silver, and Bronze counts side by side. Consecutive
Games detection using LAG().

Part 8: NOC and Region Data Quality
Unmatched NOC codes between tables. Region with the most NOC codes mapped
to it. Countries in the lookup table that never appeared in the events data.


How to Run

This project was built on SQL Server running inside a Docker container on Mac.

1. Start your SQL Server Docker container.
2. Copy both CSV files into the container at /var/opt/mssql/.
3. Open the SQL file in VS Code with the SQL Server extension connected.
4. Run the setup section first to create the database and load data.
5. Run each section independently from there.

The CSV files are not included in this repository as they are publicly
available on Kaggle under the name 120 years of Olympic history: athletes
and results by rgriffin.


Skills Demonstrated

SQL Server T-SQL
Table creation and BULK INSERT data loading
NULL handling with IS NOT NULL and TRY_CAST
Aggregate functions: COUNT, SUM, AVG, ROUND
GROUP BY, HAVING, ORDER BY, TOP N
Subqueries and correlated subqueries
INNER JOIN and LEFT JOIN across multiple tables
Window functions: RANK(), DENSE_RANK(), LAG()
PIVOT for cross-tab reporting
CASE WHEN for conditional aggregation
INFORMATION_SCHEMA for schema inspection
Docker-based SQL Server environment on Mac
