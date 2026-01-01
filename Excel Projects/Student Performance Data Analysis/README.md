**Student Academic Performance Analysis**



**Project Overview**

This project analyzes demographic, socioeconomic, and behavioral data from the UCI Machine Learning Repository to identify key drivers of academic success.

The analysis focuses on quantifying qualitative attributes to find correlations between student background (e.g., gender, support systems) and performance outcomes.



**Tools Used**: Excel (Feature Engineering, Radar Charts, Pivot Tables, Conditional Formatting)



**Key Insights**

**1.Gender Performance Gap:**

Identified a measurable performance disparity where female students achieved an average End Semester GPA of 2.32, outperforming male students at 2.17 (~7% gap).

**2.The "Support Paradox":**

Analysis revealed that students utilizing Free Academic Support scored higher on average than those paying for support, suggesting paid resources are primarily utilized by at-risk students rather than high achievers.

**3.Learning Style Correlation:**

Visual learners demonstrated higher retention and performance in End Semester exams compared to Theoretical learners.



**Dashboard**

<img width="1865" height="691" alt="dashboard_full" src="https://github.com/user-attachments/assets/f22acdf4-5845-4940-abbb-2fa02e5d870a" />



**Technical Methodology**


**1. Data Cleaning \& ETL**

**Data Transformation:** Sourced unstructured student data and standardized inconsistent formatting across demographic fields.

**Null Handling:** Removed incomplete records to ensure statistical accuracy in the final dataset.



**2. Feature Engineering (Categorical to Numerical)**

To enable mathematical analysis on text-based survey data, I engineered a standardized scoring system:

Attribute Mapping: Created a Data Dictionary to map categorical values (e.g., "Good", "Average") to a 4-point numerical scale.



Best = 4



Very Good = 3



Good = 2



Pass = 1

**Logic Application:** This allowed for the calculation of average scores across disparate groups (e.g., "Average Internal Score: 2.55").



**3. Visualization Strategy**

**Multivariate Analysis:** Utilized Radar Charts to compare the "performance shape" of male vs. female cohorts across multiple grade tiers.

**Segmentation:** Implemented interactive Slicers for Family Income, Travel Time, and Health Status to allow for deep-dive subgroup analysis.

**Comparative Analysis:** Used Stacked Bar Charts to visualize the relationship between Learning Styles (Visual vs. Theoretical) and exam results.



**How to Use**

1.Download the .xlsx file from the dashboard/ folder.

2.Open in Excel.

3.Use the "Family Income" or "Travel Time" slicers to filter the population and observe how the KPIs change dynamically.


