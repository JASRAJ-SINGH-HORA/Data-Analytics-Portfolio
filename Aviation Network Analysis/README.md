**Aviation Network Optimization \&  Route Analysis**



**-----**



**Executive Summary**



**Role:** Data Analyst | **Domain:** Aviation and Network





This project transforms raw flight data into a strategic **"Command Center"** for airline executives. 



By integrating SQL for data preparation and Power BI for advanced analytics, I analyzed **4,000+** flight routes to solve two critical business problems: 



1\. Operational Inefficiency	2. Missed Growth Opportunities.



**-----**



**Key Business Impact:**



1\. Identified High-Risk **"Cash Burn"** Routes, isolating long-haul inefficiencies hidden by standard metrics.



2\. Pinpointed 10 **"Hidden Gem"** Markets where theoretical demand exceeds supply, providing a data-backed expansion roadmap.



**-----**



**The Business Problem**

Standard airline reporting focuses on Load Factor (how full the plane is). However, this metric is misleading for financial strategy:



**The "Distance Cost" Blindspot:**



A half-empty short-distance flight loses little money, but a half-empty long-distance flight is a financial disaster. The client lacked a metric to weigh empty seats by distance.



**Reactive vs. Proactive Growth:**



Route planning was based on historical passenger data (looking backward) rather than demographic market potential (looking forward).



**-----**



**Solution Architecture**



I designed an end-to-end analytics pipeline to address these gaps.





**Data Transformation (SQL \\\& Power Query)**



**Data Cleaning:** 

Handled null values in Distance and Population columns to ensure calculation accuracy.



**Logic Implementation:**

Created a **Distance\_Type/ Haul\_Type** segmentation logic to categorize flights into actionable groups:



**Short Haul: < 800 miles**

**Medium Haul: 800 - 2500 miles**

**Long Haul: > 2500 miles**



**-----**



**Metric Engineering (DAX)**

I developed custom KPIs to quantify Risk and Opportunity:



**Metric	Formula	Strategic Purpose**



**1.Cash Burn Index = (Seats - Passengers) \* Distance**	

Weights empty seats by miles flown Instantly highlights the most expensive waste in the network.



**2.Market Potential Score = (Origin\\\_Pop \\\* Dest\\\_Pop) / Distance²**	

Adapts the Gravity Model of Trade to estimate theoretical passenger demand between two cities.



**3.Opportunity Gap= Potential Score vs Actual Passengers**	

Identifies markets with high gravity but low current traffic (Under-served Markets).



**-----**



**Dashboard Features (Power BI)**



**1.Aviation Data Analysis Report**

!\[Page 1](screenshots/1.png)



Purpose: The Executive Summary—an immediate **"Health Check"** of the entire airline network.



Key Visuals: High-level Card KPIs displaying **Total Passengers**, **Total Flights**, and **Distance Flown**.



Insight: Provides a **snapshot** **of volume and scale**, allowing stakeholders to track year-to-date performance against operational targets.



**2.Trends and Seasonality**

!\[Page 2](screenshots/2.png)



Purpose: Analyzes flight demand patterns over time to identify **peak travel windows**.



Key Visuals: Time-series Line Charts tracking **Passenger volume and Flight frequency** by month and quarter.



Insight: Identifies **seasonal spikes** (e.g., Holiday demand) and low-traffic periods, enabling better capacity planning during off-peak months.



**3.Seat Utilization and Efficiency**

!\[Page 3](screenshots/3.png)



Purpose: Measures how effectively the airline is filling its **available capacity** (Load Factor).



Key Visuals: Visualization of **Occupancy Rates** and **Empty Seats** across different sectors.



Insight: Highlights **inefficiency gaps** where aircraft are flying with too many empty seats, directly impacting profitability.



**4.Network Analysis**

!\[Page 4](screenshots/4.png)



Purpose: Helps finding the balance between **operational risk against market opportunity**.



Key Visuals: A Risk Matrix (Scatter Plot) plotting Distance vs. **Cash Burn**, a Growth Engine (Bar Chart) identifying **under-served markets**, and dynamic KPI cards.



Insight: Enables executives to simultaneously **target high-cost long-distance routes** for optimization and identify **"Sleeping Giant"** cities for expansion.



**-----**



**Project Structure**



Aviation Network Analysis

├──  Avation\_Data\_Analysis.sql      		 # The SQL Script



├── Aviation\_Network\_Analysis.pbix          # The interactive Power BI dashboard file



└── Screenshots 			        		 # Screenshots of the Power BI Dashboard     

&nbsp;


