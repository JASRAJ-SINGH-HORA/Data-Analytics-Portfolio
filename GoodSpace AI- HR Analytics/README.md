**HR Analytics: Recruitment Process Optimization \& Strategy**



**Executive Summary**

This project is a comprehensive data analytics solution designed to audit and optimize a company's recruitment funnel. By transforming raw event logs into actionable intelligence, the project addresses two critical business objectives: Operational Efficiency (Speed \& Throughput) and Strategic Quality (Bias Elimination \& Sourcing Strategy).



The analysis follows a strict Problem-Solution methodology, starting with raw data modeling in SQL to answer 13 specific business questions, followed by a dynamic Power BI dashboard for executive monitoring.



---



**Tech Stack \& Workflow**

&nbsp;**Database:** MySQL 8.0 (Star Schema Design)

&nbsp;**Visualization:** Power BI (DAX, Interactive Reporting)

&nbsp;**Domain:** HR Tech / Recruitment Analytics



**Data Architecture** (Star Schema)

The raw data was transformed from a vertical event log into a relational Star Schema to enable high-performance analysis:

&nbsp;Fact Table: `Funnel\_Analysis\_Table` 

&nbsp;Dimension Tables: `Jobs\_Master`, `Candidates\_Master`, `AI\_Log`.



---



**Part 1: SQL Analysis** (The "Problem-First" Approach)

Before visualizing, I solved 13 Critical Business Problems using SQL. The analysis is divided into two phases:



&nbsp;**Phase A: Operational Efficiency**

| Problem Statement | SQL Solution | Key Insight |

| :--- | :--- | :--- |

| 1. Baseline Speed | Calculated avg hours between `Applied` and `Shortlist` timestamps. | Avg time to shortlist is ~10.7 hours. |

| 2. Claim Compliance | Counted % of decisions made within the 24-hour target. | 84% of decisions meet the claims. |

| 3. Channel Velocity | Compared speed of `WhatsApp` vs. `Email` candidates. | WhatsApp is ~13x faster than Email. |

| 4. Vendor Friction | Calculated drop-off rates at the "Video Interview" stage per company. | Some vendors have >35% drop-off, indicating broken processes. |

| 5. Peak Volume | Aggregated application timestamps by Day of Week. | Thursdays see the highest application volume. |



&nbsp;**Phase B: Quality \& Strategy**

| Problem Statement | SQL Solution | Key Insight |

| :--- | :--- | :--- |

| 6. AI Audit | Correlated `AI\_Match\_Score` with `Shortlist\_Rate`. | Recruiters are ignoring high AI scores (Trust Gap identified). |

| 7. False Negatives | Filtered for High Score (>90) candidates with NULL shortlist. | Generated a "Call List" of ignored top talent. |

| 8. Hiring Risk | `Candidate Supply` vs. `Drop-off Rate` per role. | DevOps roles are "High Risk" (Low Supply, High Friction). |



(See `HR\_Analytics.sql` for the complete code and logic).



---



**Part 2: Power BI Dashboard (The Decision Engine**)

The SQL insights were translated into a 2-page interactive dashboard.



&nbsp;**Page 1: Process Overview**

Focus: Speed, Bottlenecks, and Funnel Health.

!\[Process Overview Dashboard](Process Overview.png)

&nbsp;KPIs: Tracks Speed (10.7h), Claim Compliance (84%), and Drop-off Rates.

&nbsp;Heatmap: Instantly flags companies with high "Video Friction" (Red indicators).

&nbsp;Speed Analysis: Histogram proves most candidates are processed in 0-12 hours.

&nbsp;Channel Insight: Visualizes the massive speed advantage of WhatsApp.



&nbsp;**Page 2: Quality and Strategic Analysis**

Focus: Bias Detection and Sourcing Strategy.

!\[Quality and Strategic Analysis Dashboard]((screenshots/Quality and Strategic Analysis.png)

&nbsp;The Trust Gap: Scatter plot reveals a flat correlation between AI Score and Recruiter Selection, proving bias.

&nbsp;Hiring Risk Quadrant: Segregates roles into "Easy Hires" vs. "Critical Risks" based on supply and difficulty.

&nbsp;False Negatives List: A direct table listing high-potential candidates who were overlooked.



(See `hr analytics.pbix` to access the interactive dashboard).

---



Folder Structure

├── SQL\_Scripts   

├── HR\_Analytics\_Dashboard.pbix          

└── README.md


