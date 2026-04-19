# Retail Sales Analysis & Data Integrity Audit

## 📌 Project Overview
This project demonstrates an end-to-end data pipeline: transitioning raw retail data into a structured PostgreSQL database for high-level business intelligence. Moving beyond standard analysis, I implemented a **Data Integrity Audit** phase to reconcile calculations and ensure data reliability—a critical requirement for corporate-level financial reporting.

## 🛠️ Tech Stack
* **Database:** PostgreSQL (via pgAdmin 4)
* **Scripting:** SQL (VS Code)
* **Data Source:** MS Excel (CSV)
* **Key Skills:** Data Cleaning, Integrity Auditing, Exploratory Data Analysis (EDA)

## 🚀 The Workflow (My Process)

### 1. Schema Definition & Ingestion
* Developed a robust table schema with optimized data types.
* Managed raw CSV ingestion into PostgreSQL, ensuring data consistency and handling encoding requirements.

### 2. Data Cleaning
* Performed deep-cleaning to identify and remove records with missing values in critical transactional fields.
* Verified dataset completeness to ensure high-accuracy modeling and reporting.

### 3. Data Integrity Audit (The "Deloitte" Approach)
Before performing business analysis, I executed a dedicated audit phase to validate data reliability:
* **Calculation Reconciliation:** Verified that `quantiy * price_per_unit` matched the `total_sale`.
* **Business Logic Audit:** Flagged "Negative Margin" anomalies where COGS exceeded the sale price, identifying potential upstream data entry errors.

### 4. Business Analysis & Insights
Solved 10+ business-critical problems to uncover retail trends:
* **Time-Series Analysis:** Identified peak sales periods and high-performing shifts (Morning/Afternoon/Evening).
* **Customer Segmentation:** Isolated top-spending customers and analyzed unique category shopping behaviors.

## 📂 Files in this Repository
* **`Retail_sales-analysis.sql`**: Complete SQL workflow including setup, cleaning, and final analysis.
* **`SQL - Retail Sales Analysis_utf.csv`**: The raw source data used for the analysis.

---
**Author:** Sanchi Gupta 
*Data Analytics Professional | Raebareli, India* *Specializing in building reliable, audit-ready data solutions.*
