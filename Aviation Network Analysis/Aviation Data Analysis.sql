/*
=============================================================================
Project:       Aviation Data Analysis 
Description:   A comprehensive SQL analysis of airport traffic, seat utilization,
               route efficiency, and seasonal trends.
Database:      airport_db
SQL Dialect:   MySQL 
Author:        Jasraj Singh Hora
=============================================================================
*/

USE airport_db;
select count(*) from airports;
-- ==========================================================================
-- PART A: PERFORMANCE & ROUTE EFFICIENCY
-- ==========================================================================

/* 1. Total Passengers per Route
   Objective: Calculate the total passenger volume for each Origin-Destination pair.
*/
SELECT 
    Origin_airport,
    Destination_airport,
    SUM(Passengers) AS Total_Passengers
FROM 
    airports
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Origin_airport, 
    Destination_airport;


/* 2. Average Seat Utilization
   Objective: Calculate efficiency (Passengers / Seats) per route.
   Note: Uses NULLIF to prevent division by zero errors.
*/
SELECT 
    Origin_airport, 
    Destination_airport, 
    AVG(CAST(Passengers AS FLOAT) / NULLIF(Seats, 0)) * 100 AS Average_Seat_Utilization
FROM 
    airports
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Average_Seat_Utilization DESC;


/* 3. Top 5 Busiest Routes
   Objective: Identify the top 5 routes by total passenger volume.
*/
SELECT 
    Origin_airport, 
    Destination_airport, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Total_Passengers DESC
LIMIT 5;


/* 4. Origin City Metrics
   Objective: Calculate flight count and passenger volume per Origin City.
*/
SELECT 
    Origin_city, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports
GROUP BY 
    Origin_city
ORDER BY 
    Origin_city;


/* 5. Operational Reach (Total Distance)
   Objective: Calculate the total distance flown from each airport.
*/
SELECT 
    Origin_airport, 
    SUM(Distance) AS Total_Distance
FROM 
    airports
GROUP BY 
    Origin_airport
ORDER BY 
    Origin_airport;


/* 6. Monthly Seasonality
   Objective: Group data by Year/Month to view trends in flights and distance.
*/
SELECT 
    YEAR(Fly_date) AS Year, 
    MONTH(Fly_date) AS Month, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers, 
    AVG(Distance) AS Avg_Distance
FROM 
    airports
GROUP BY 
    YEAR(Fly_date), 
    MONTH(Fly_date)
ORDER BY 
    Year, 
    Month;


/* 7. Underutilized Routes (Ratio < 0.5)
   Objective: Filter for routes where passenger-to-seat ratio is below 50%.
*/
SELECT 
    Origin_airport, 
    Destination_airport, 
    SUM(Passengers) AS Total_Passengers, 
    SUM(Seats) AS Total_Seats, 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) AS Passenger_to_Seats_Ratio
FROM 
    airports
GROUP BY 
    Origin_airport, 
    Destination_airport
HAVING 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) < 0.5
ORDER BY 
    Passenger_to_Seats_Ratio;


/* 8. Top 3 Most Active Airports
   Objective: Determine top 3 origin airports by flight frequency.
*/
SELECT 
    Origin_airport, 
    COUNT(Flights) AS Total_Flights
FROM 
    airports
GROUP BY 
    Origin_airport
ORDER BY 
    Total_Flights DESC
LIMIT 3;


/* 9. Traffic to Bend, OR
   Objective: Identify top feeder cities sending flights/pax to Bend, OR (excluding self).
*/
SELECT 
    Origin_city, 
    COUNT(Flights) AS Total_Flights, 
    SUM(Passengers) AS Total_Passengers
FROM 
    airports
WHERE 
    Destination_city = 'Bend, OR' 
    AND Origin_city <> 'Bend, OR'
GROUP BY 
    Origin_city
ORDER BY 
    Total_Flights DESC, 
    Total_Passengers DESC
LIMIT 3;


/* 10. Longest Flight Route
   Objective: Identify the single longest route by distance.
*/
SELECT 
    Origin_airport, 
    Destination_airport, 
    MAX(Distance) AS Longest_Distance
FROM 
    airports
GROUP BY 
    Origin_airport, 
    Destination_airport
ORDER BY 
    Longest_Distance DESC
LIMIT 1;


-- ==========================================================================
-- PART B: TRENDS & YEAR-OVER-YEAR GROWTH
-- ==========================================================================

/* 11. Peak & Off-Peak Analysis
   Objective: Identify the single most and least busy months across the dataset.
*/
WITH Monthly_Flights AS (
    SELECT 
        MONTH(Fly_date) AS Month, 
        COUNT(Flights) AS Total_Flights
    FROM 
        airports
    GROUP BY 
        MONTH(Fly_date)
)
SELECT 
    Month, 
    Total_Flights,
    CASE 
        WHEN Total_Flights = (SELECT MAX(Total_Flights) FROM Monthly_Flights) THEN 'Most Busy'
        WHEN Total_Flights = (SELECT MIN(Total_Flights) FROM Monthly_Flights) THEN 'Least Busy'
        ELSE NULL
    END AS Month_Status
FROM 
    Monthly_Flights
WHERE 
    Total_Flights = (SELECT MAX(Total_Flights) FROM Monthly_Flights) 
    OR Total_Flights = (SELECT MIN(Total_Flights) FROM Monthly_Flights);


/* 12. YoY Passenger Growth
   Objective: Calculate Year-Over-Year % growth for routes.
*/
WITH Passenger_Summary AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date) AS Year, 
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),
Passenger_Growth AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Passengers,
        LAG(Total_Passengers) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Year) AS Previous_Year_Passengers
    FROM 
        Passenger_Summary
)
SELECT 
    Origin_airport, 
    Destination_airport, 
    Year, 
    Total_Passengers, 
    CASE 
        WHEN Previous_Year_Passengers IS NOT NULL THEN 
            ((Total_Passengers - Previous_Year_Passengers) * 100.0 / NULLIF(Previous_Year_Passengers, 0))
        ELSE NULL 
    END AS Growth_Percentage
FROM 
    Passenger_Growth
ORDER BY 
    Origin_airport, 
    Destination_airport, 
    Year;


/* 13. Consistent Growth Routes
   Objective: Identify routes that have shown positive growth every single year.
*/
WITH Flight_Summary AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date) AS Year, 
        COUNT(Flights) AS Total_Flights
    FROM 
        airports
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),
Flight_Growth AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Flights,
        LAG(Total_Flights) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Year) AS Previous_Year_Flights
    FROM 
        Flight_Summary
),
Growth_Rates AS (
    SELECT 
        Origin_airport, 
        Destination_airport, 
        Year, 
        Total_Flights,
        CASE 
            WHEN Previous_Year_Flights IS NOT NULL AND Previous_Year_Flights > 0 THEN 
                ((Total_Flights - Previous_Year_Flights) * 100.0 / Previous_Year_Flights)
            ELSE NULL 
        END AS Growth_Rate,
        CASE 
            WHEN Previous_Year_Flights IS NOT NULL AND Total_Flights > Previous_Year_Flights THEN 1
            ELSE 0 
        END AS Growth_Indicator
    FROM 
        Flight_Growth
)
SELECT 
    Origin_airport, 
    Destination_airport,
    MIN(Growth_Rate) AS Minimum_Growth_Rate,
    MAX(Growth_Rate) AS Maximum_Growth_Rate
FROM 
    Growth_Rates
WHERE 
    Growth_Indicator = 1
GROUP BY 
    Origin_airport, 
    Destination_airport
HAVING 
    MIN(Growth_Indicator) = 1
ORDER BY 
    Origin_airport, 
    Destination_airport;


/* 14. Weighted Utilization (Top 3)
   Objective: Rank airports by seat utilization, weighted by flight volume.
*/
WITH Utilization_Ratio AS (
    SELECT 
        Origin_airport, 
        SUM(Passengers) AS Total_Passengers, 
        SUM(Seats) AS Total_Seats, 
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0) AS Passenger_Seat_Ratio
    FROM 
        airports
    GROUP BY 
        Origin_airport
),
Weighted_Utilization AS (
    SELECT 
        Origin_airport, 
        Total_Passengers, 
        Total_Seats, 
        Total_Flights,
        Passenger_Seat_Ratio, 
        -- Weight the ratio by the total number of flights across the network
        (Passenger_Seat_Ratio * Total_Flights) / SUM(Total_Flights) OVER () AS Weighted_Utilization
    FROM 
        Utilization_Ratio
)
SELECT 
    Origin_airport, 
    Total_Passengers, 
    Total_Seats, 
    Total_Flights, 
    Weighted_Utilization
FROM 
    Weighted_Utilization
ORDER BY 
    Weighted_Utilization DESC
LIMIT 3;


/* 15. Peak Month per City
   Objective: Identify the specific month with max passengers for each city.
*/
WITH Monthly_Passenger_Count AS (
    SELECT 
        Origin_city,
        YEAR(Fly_date) AS Year,
        MONTH(Fly_date) AS Month,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports
    GROUP BY 
        Origin_city, 
        YEAR(Fly_date), 
        MONTH(Fly_date)
),
Max_Passengers_Per_City AS (
    SELECT 
        Origin_city, 
        MAX(Total_Passengers) AS Peak_Passengers
    FROM 
        Monthly_Passenger_Count
    GROUP BY 
        Origin_city
)
SELECT 
    mpc.Origin_city, 
    mpc.Year, 
    mpc.Month, 
    mpc.Total_Passengers
FROM 
    Monthly_Passenger_Count mpc
JOIN 
    Max_Passengers_Per_City mp ON mpc.Origin_city = mp.Origin_city 
    AND mpc.Total_Passengers = mp.Peak_Passengers
ORDER BY 
    mpc.Origin_city, 
    mpc.Year, 
    mpc.Month;


/* 16. Largest YoY Decline
   Objective: Identify routes with the sharpest drop in passengers.
*/
WITH Yearly_Passenger_Count AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        YEAR(Fly_date) AS Year,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports
    GROUP BY 
        Origin_airport, 
        Destination_airport, 
        YEAR(Fly_date)
),
Yearly_Decline AS (
    SELECT 
        y1.Origin_airport,
        y1.Destination_airport,
        y1.Year AS Year1,
        y1.Total_Passengers AS Passengers_Year1,
        y2.Year AS Year2,
        y2.Total_Passengers AS Passengers_Year2,
        ((y2.Total_Passengers - y1.Total_Passengers) / NULLIF(y1.Total_Passengers, 0)) * 100 AS Percentage_Change
    FROM 
        Yearly_Passenger_Count y1
    JOIN 
        Yearly_Passenger_Count y2
        ON y1.Origin_airport = y2.Origin_airport
        AND y1.Destination_airport = y2.Destination_airport
        AND y2.Year = y1.Year + 1
)
SELECT 
    Origin_airport,
    Destination_airport,
    Year1,
    Year2,
    Passengers_Year1,
    Passengers_Year2,
    Percentage_Change
FROM 
    Yearly_Decline
WHERE 
    Percentage_Change < 0 
ORDER BY 
    Percentage_Change ASC
LIMIT 5;


/* 17. Frequent Flights but Low Utilization
   Objective: Routes with >= 10 flights but < 50% occupancy.
*/
WITH Flight_Stats AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers,
        SUM(Seats) AS Total_Seats,
        (SUM(Passengers) / NULLIF(SUM(Seats), 0)) AS Avg_Seat_Utilization
    FROM 
        airports
    GROUP BY 
        Origin_airport, Destination_airport
)
SELECT 
    Origin_airport,
    Destination_airport,
    Total_Flights,
    Total_Passengers,
    Total_Seats,
    ROUND(Avg_Seat_Utilization * 100, 2) AS Avg_Seat_Utilization_Percentage
FROM 
    Flight_Stats
WHERE 
    Total_Flights >= 10 
    AND Avg_Seat_Utilization < 0.5
ORDER BY 
    Avg_Seat_Utilization_Percentage ASC;


/* 18. Longest Average Distance Routes
   Objective: Calculate avg distance per city-pair.
*/
WITH Distance_Stats AS (
    SELECT 
        Origin_city,
        Destination_city,
        AVG(Distance) AS Avg_Flight_Distance
    FROM 
        airports
    GROUP BY 
        Origin_city, 
        Destination_city
)
SELECT 
    Origin_city,
    Destination_city,
    ROUND(Avg_Flight_Distance, 2) AS Avg_Flight_Distance
FROM 
    Distance_Stats
ORDER BY 
    Avg_Flight_Distance DESC;


/* 19. Total Network Growth (Yearly)
   Objective: Macro-view of total flights and passenger growth per year.
*/
WITH Yearly_Summary AS (
    SELECT 
        YEAR(Fly_date) AS Year, 
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports
    GROUP BY 
        YEAR(Fly_date)
)
, Yearly_Growth AS (
    SELECT 
        Year,
        Total_Flights,
        Total_Passengers,
        LAG(Total_Flights) OVER (ORDER BY Year) AS Prev_Flights,
        LAG(Total_Passengers) OVER (ORDER BY Year) AS Prev_Passengers
    FROM 
        Yearly_Summary
)
SELECT 
    Year,
    Total_Flights,
    Total_Passengers,
    ROUND(((Total_Flights - Prev_Flights) / NULLIF(Prev_Flights, 0) * 100), 2) AS Flight_Growth_Percentage,
    ROUND(((Total_Passengers - Prev_Passengers) / NULLIF(Prev_Passengers, 0) * 100), 2) AS Passenger_Growth_Percentage
FROM 
    Yearly_Growth
ORDER BY 
    Year;


/* 20. Busiest Routes by Weighted Distance
   Objective: Top routes by distance * frequency.
*/
WITH Route_Distance AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        SUM(Distance) AS Total_Distance,
        SUM(Flights) AS Total_Flights
    FROM 
        airports
    GROUP BY 
        Origin_airport, 
        Destination_airport
),
Weighted_Routes AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        Total_Distance,
        Total_Flights,
        Total_Distance * Total_Flights AS Weighted_Distance
    FROM 
        Route_Distance
)
SELECT 
    Origin_airport,
    Destination_airport,
    Total_Distance,
    Total_Flights,
    Weighted_Distance
FROM 
    Weighted_Routes
ORDER BY 
    Weighted_Distance DESC
LIMIT 3;

