/*
=============================================================================
Project:       HR Analytics
Description:   A comprehensive SQL analysis of hiring speed, funnel leakage,
               AI algorithm bias, and sourcing channel efficiency.
Database:      HR_Analytics
SQL Dialect:   MySQL
Author:        Jasraj Singh Hora
=============================================================================
*/

-- ==========================================================================
-- STEP 1: DATABASE & RAW TABLE SETUP
-- ==========================================================================

CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

-- 1. Jobs Table 
CREATE TABLE Jobs_Master (
    Job_ID VARCHAR(50) PRIMARY KEY,
    Role_Title VARCHAR(100),
    Company_ID INT,
    Location VARCHAR(100),
    Posted_Date DATETIME,
    Target_Hire_Date DATETIME,
    Salary_Range VARCHAR(50),
    Required_Skills TEXT
);

-- 2. Candidates Table 
CREATE TABLE Candidates_Master (
    Candidate_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Target_Role VARCHAR(100),
    Signup_Date DATETIME,
    Video_Resume_Uploaded VARCHAR(10), -- 'Yes' or 'No'
    Preferred_Communication VARCHAR(50),
    Skills_Owned TEXT
);

-- 3. AI Log Table 
CREATE TABLE AI_Log (
    Job_ID VARCHAR(50),
    Candidate_ID VARCHAR(50),
    AI_Match_Score INT,
    Match_Reason TEXT,
    INDEX idx_ai_job_cand (Job_ID, Candidate_ID)
);

-- 4. Funnel Events Table 
CREATE TABLE Funnel_Events (
    User_ID VARCHAR(50),
    Job_ID VARCHAR(50),
    Event_Type VARCHAR(50),
    Timestamp DATETIME,
    INDEX idx_event_user_job (User_ID, Job_ID)
);


-- ==========================================================================
-- STEP 2: CREATE THE FACT TABLE 
-- ==========================================================================

/* We create  Fact Table, This transforms vertical logs into a candidate-centric timeline. */

CREATE TABLE Funnel_Analysis_Table (
    Candidate_ID VARCHAR(50),
    Job_ID VARCHAR(50),
    Company_ID INT,
    Role_Title VARCHAR(100),
    Communication_Channel VARCHAR(50),
    Applied_Time DATETIME,
    Video_Start_Time DATETIME,
    Video_End_Time DATETIME,
    Shortlist_Time DATETIME,
    Hours_To_Shortlist DECIMAL(10, 2),
    Hours_To_Video DECIMAL(10, 2),
    PRIMARY KEY (Candidate_ID, Job_ID)
);

INSERT INTO Funnel_Analysis_Table
SELECT 
    f.User_ID AS Candidate_ID,
    f.Job_ID,
    j.Company_ID,
    j.Role_Title,
    c.Preferred_Communication,
    MAX(CASE WHEN f.Event_Type = 'Applied' THEN f.Timestamp END) AS Applied_Time,
    MAX(CASE WHEN f.Event_Type = 'Video_Interview_Started' THEN f.Timestamp END) AS Video_Start_Time,
    MAX(CASE WHEN f.Event_Type = 'Video_Interview_Completed' THEN f.Timestamp END) AS Video_End_Time,
    MAX(CASE WHEN f.Event_Type = 'Recruiter_Shortlisted' THEN f.Timestamp END) AS Shortlist_Time,
    
    TIMESTAMPDIFF(HOUR, 
        MAX(CASE WHEN f.Event_Type = 'Applied' THEN f.Timestamp END), 
        MAX(CASE WHEN f.Event_Type = 'Recruiter_Shortlisted' THEN f.Timestamp END)
    ) AS Hours_To_Shortlist,
    TIMESTAMPDIFF(HOUR, 
        MAX(CASE WHEN f.Event_Type = 'Applied' THEN f.Timestamp END), 
        MAX(CASE WHEN f.Event_Type = 'Video_Interview_Started' THEN f.Timestamp END)
    ) AS Hours_To_Video
FROM Funnel_Events f
JOIN Jobs_Master j ON f.Job_ID = j.Job_ID
LEFT JOIN Candidates_Master c ON f.User_ID = c.Candidate_ID
GROUP BY f.User_ID, f.Job_ID, j.Company_ID, j.Role_Title, c.Preferred_Communication;


-- ==========================================================================
-- STEP 3: PROBLEM STATEMENTS AND SOLUTIONS
-- ==========================================================================

/* --------------------------------------------------------------------------
   PART A: OPERATIONAL EFFICIENCY
   -------------------------------------------------------------------------- */

/* 1. 
   Problem: "What is the average time (in hours) to shortlist a candidate?"
   Solution: Calculate average hours for completed shortlists.
*/
SELECT 
    ROUND(AVG(Hours_To_Shortlist), 2) AS Avg_Hours_To_Shortlist
FROM Funnel_Analysis_Table
WHERE Shortlist_Time IS NOT NULL;


/* 2. 
   Problem: "What percentage of hiring decisions meet the 24-hour target?"
   Solution: Count decisions <= 24h divided by total decisions.
*/
SELECT 
    ROUND(
        (COUNT(CASE WHEN Hours_To_Shortlist <= 24 THEN 1 END) / COUNT(*)) * 100, 
    2) AS SLA_Compliance_Rate
FROM Funnel_Analysis_Table
WHERE Shortlist_Time IS NOT NULL;


/* 3. 
   Problem: "What percentage of candidates abandon the process during the video interview?"
   Solution: 1 - (Completed / Started).
*/
SELECT 
    ROUND(
        (1 - (COUNT(Video_End_Time) / NULLIF(COUNT(Video_Start_Time), 0))) * 100, 
    2) AS Video_Dropoff_Rate
FROM Funnel_Analysis_Table;


/* 4. 
   Problem: "How many unique jobs are currently being actively recruited for?"
   Solution: Distinct count of Job IDs.
*/
SELECT COUNT(DISTINCT Job_ID) AS Active_Job_Count FROM Jobs_Master;


/* 5. 
   Problem: "Group the hiring speed into time buckets (0-12h, 12-24h) to see volume distribution."
   Solution: Case statement to create bins, then count volume per bin.
*/
SELECT 
    CASE 
        WHEN Hours_To_Shortlist <= 12 THEN '0-12 Hours'
        WHEN Hours_To_Shortlist <= 24 THEN '12-24 Hours'
        WHEN Hours_To_Shortlist <= 48 THEN '24-48 Hours'
        ELSE '48+ Hours'
    END AS Speed_Bucket,
    COUNT(*) AS Candidate_Count
FROM Funnel_Analysis_Table
WHERE Shortlist_Time IS NOT NULL
GROUP BY Speed_Bucket
ORDER BY Candidate_Count DESC;


/* 6. 
   Problem: "Rank companies by their Video Drop-off Rate to identify bad actors."
   Solution: Group by Company_ID, calculate drop-off %, sort descending.
*/
SELECT 
    Company_ID,
    ROUND((1 - (COUNT(Video_End_Time) / NULLIF(COUNT(Video_Start_Time), 0))) * 100, 2) AS Dropoff_Pct
FROM Funnel_Analysis_Table
GROUP BY Company_ID
HAVING COUNT(Video_Start_Time) > 5
ORDER BY Dropoff_Pct DESC
LIMIT 10;


/* 7. 
   Problem: "Compare the average speed to reach the video stage for WhatsApp vs. Email."
   Solution: Average Hours_To_Video grouped by Channel.
*/
SELECT 
    Communication_Channel,
    ROUND(AVG(Hours_To_Video), 2) AS Avg_Hours_To_Video
FROM Funnel_Analysis_Table
WHERE Video_Start_Time IS NOT NULL
GROUP BY Communication_Channel
ORDER BY Avg_Hours_To_Video ASC;


/* 8. 
   Problem: "Show the raw candidate count at every stage of the funnel to visualize leakage."
   Solution: Count distinct users per event type.
*/
SELECT 
    Event_Type AS Funnel_Stage,
    COUNT(DISTINCT User_ID) AS Volume
FROM Funnel_Events
WHERE Event_Type IN ('Viewed_Job', 'Applied', 'Video_Interview_Started', 'Recruiter_Shortlisted')
GROUP BY Funnel_Stage
ORDER BY Volume DESC;


/* 9. 
   Problem: "Which day of the week sees the highest application volume?"
   Solution: Extract Day Name from Applied_Time and count rows.
*/
SELECT 
    DAYNAME(Applied_Time) AS Day_Name,
    COUNT(*) AS Application_Count
FROM Funnel_Analysis_Table
WHERE Applied_Time IS NOT NULL
GROUP BY Day_Name
ORDER BY Application_Count DESC;


/* --------------------------------------------------------------------------
   PART B: QUALITY & STRATEGIC ANALYSIS
   -------------------------------------------------------------------------- */

/* 10. 
   Problem: "Do recruiters shortlist candidates with higher AI scores? (Bias Check)"
   Solution: Bucket AI scores into ranges (10s) and avg the Shortlist flag.
*/
SELECT 
    FLOOR(a.AI_Match_Score / 10) * 10 AS Score_Range,
    ROUND(AVG(CASE WHEN f.Shortlist_Time IS NOT NULL THEN 1 ELSE 0 END) * 100, 2) AS Shortlist_Probability
FROM AI_Log a
JOIN Funnel_Analysis_Table f ON a.Candidate_ID = f.Candidate_ID AND a.Job_ID = f.Job_ID
GROUP BY Score_Range
ORDER BY Score_Range ASC;


/* 11. 
   Problem: "List candidates with AI Score > 90 who were NOT shortlisted."
   Solution: Filter for High Score AND Null Shortlist Time.
*/
SELECT 
    c.Name,
    f.Role_Title,
    a.AI_Match_Score,
    c.Skills_Owned
FROM Funnel_Analysis_Table f
JOIN AI_Log a ON f.Candidate_ID = a.Candidate_ID AND f.Job_ID = a.Job_ID
JOIN Candidates_Master c ON f.Candidate_ID = c.Candidate_ID
WHERE a.AI_Match_Score >= 90 
  AND f.Shortlist_Time IS NULL
LIMIT 20;


/* 12. 
   Problem: "Which communication channel do candidates prefer based on their Role?"
   Solution: Count by Role and Channel.
*/
SELECT 
    Role_Title,
    Communication_Channel,
    COUNT(*) AS Preference_Count
FROM Funnel_Analysis_Table
GROUP BY Role_Title, Communication_Channel
ORDER BY Role_Title, Preference_Count DESC;


/* 13. 
   Problem: "Calculate Supply (Volume) and Friction (Drop-off) for each Role."
   Solution: Aggregate counts and drop-off rates by Role Title.
*/
SELECT 
    Role_Title,
    COUNT(DISTINCT Candidate_ID) AS Supply_Volume,
    ROUND((1 - (COUNT(Video_End_Time) / NULLIF(COUNT(Video_Start_Time), 0))), 2) AS Friction_Score
FROM Funnel_Analysis_Table
GROUP BY Role_Title
ORDER BY Friction_Score DESC;
