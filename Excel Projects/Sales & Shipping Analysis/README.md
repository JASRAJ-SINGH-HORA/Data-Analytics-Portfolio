**Sales \& Shipping Logistics Analysis**



**Project Overview**

This project analyzes a dataset of **2,100 orders** to evaluate shipping efficiency and sales performance. The goal was to identify cost-saving opportunities in logistics and assess the impact of discounting strategies on revenue.



**Tools Used:** Excel (Pivot Tables, Slicers, KPI Calculations, Data Cleaning)



**Key Findings**

**1.Shipping Efficiency:**

Validated a shipping cost structure of ₹13.82 per order (0.73% of total sales), confirming high operational efficiency.

**2.Revenue Strategy:**

Discounts account for only 0.46% of total revenue, indicating strong product demand without reliance on aggressive promotions.

**3.Logistics Gap:**

Identified that "Delivery Truck" mode lags in volume compared to air transport, despite a significantly higher Average Order Value (AOV), suggesting a potential area for threshold optimization.



**Dashboard**

!\[Dashboard Screenshot](screenshots/dashboard\_full.png)



**Technical Methodology**

**1. Data Cleaning \& ETL**

**Standardization:** Converted inconsistent date formats to a unified structure for time-series analysis.

**Data Integrity:** Removed null values to ensure accurate aggregation of core metrics.

**Normalization:** Categorized raw order quantities into distinct "Order Type" segments (e.g., Mini, Small, Extra Large) to standardize volume analysis.



**2. Feature Engineering**

Created calculated fields to measure specific business KPIs:



Shipping Cost per Order = Total Shipping Cost / Total Orders



Average Order Value (AOV) = Total Sales / Total Orders



Shipping % of Sales = (Total Shipping Cost / Total Sales) \* 100



**3. Visualization \& Interaction**

Designed an interactive dashboard using Slicers for dynamic filtering by Order Quantity, Ship Mode, and Month.

Implemented Pivot Charts to visualize the relationship between "Sales by Order Type" and "Order Priority".

Used a combo chart to overlay "Free Shipping" volume against Total Sales by Ship Mode.





**How to Use**

1.Download the raw file from the dashboard/ folder.

2.Open in Excel (2016 or later recommended).

3.Use the Slicers on the left panel to filter the data.

