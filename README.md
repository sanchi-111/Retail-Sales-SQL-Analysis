# Retail Sales Analysis & Data Integrity Audit

**Data Analytics Portfolio Project | PostgreSQL Data Engineering, Virtual Views & Business Intelligence**

---

## 📑 Table of Contents
* [⚡ TLDR — Operational Snapshot](#-tldr--operational-snapshot)
* [🎯 Project Overview & Objective](#-project-overview--objective)
* [🛠️ Tech Stack](#️-tech-stack)
* [🏗️ Data Pipeline & Virtual View Architecture](#️-data-pipeline--virtual-view-architecture)
* [🔍 Data Integrity & Quality Audit](#-data-integrity--quality-audit)
* [📊 Deep Analysis & Core Business Findings](#-deep-analysis--core-business-findings)
* [📂 Files in this Repository](#-files-in-this-repository)
* [👤 Author](#-author)

---

## ⚡ TLDR — Operational Snapshot

| Metric / Finding | Status | Impact |
| :--- | :--- | :--- |
| **Category Efficiency Leader** | 🟢 **OPTIMAL** | **Beauty** leads in profit margin efficiency (**47.92%**), despite lower overall revenue volume than Electronics. |
| **Peak Sales Velocity** | 🔵 **HIGH** | **Evening Shift** dominates sales volume, generating **$475,940.00** across 1,062 total orders. |
| **Data Integrity Verification** | 🟢 **VERIFIED** | 100% calculation reconciliation between unit price, quantity, COGS, and `total_sale`. |
| **VIP Customer Cohorts** | 🟣 **HIGH VALUE** | Isolated top-spending customers (`> $2,000` total spend) for targeted retention and RFM loyalty programs. |

---

## 🎯 Project Overview & Objective

This project demonstrates an end-to-end data pipeline: transitioning raw retail transaction data into a structured PostgreSQL database for high-level business intelligence. Moving beyond standard analysis, I implemented a **Data Integrity Audit** phase to reconcile calculations, eliminate anomalies, and construct a virtual view architecture (`retail_sales_transformed`) to ensure data reliability—a critical requirement for corporate-level financial reporting.

---

## 🛠️ Tech Stack

* **Database:** PostgreSQL (via pgAdmin 4)
* **Scripting:** SQL (VS Code / pgAdmin Editor)
* **Data Source:** MS Excel / Cleaned CSV (`SQL - Retail Sales Analysis_utf.csv`)
* **Key Skills:** Data Cleaning, Integrity Auditing, CTEs & Window Functions, Virtual Views, Exploratory Data Analysis (EDA)

---

## 🏗️ Data Pipeline & Virtual View Architecture

┌─────────────────────────────────┐
│     Raw CSV Ingestion           │
│  (SQL - Retail Sales_utf.csv) │
└────────────────┬────────────────┘
│
▼
┌─────────────────────────────────┐
│      Base Table                 │  <-- Immutable Physical Storage
│    (retail_sales)             │
└────────────────┬────────────────┘
│
▼
┌─────────────────────────────────┐
│    Virtual Intelligence View    │  <-- Dynamic Calculation Layer
│ (retail_sales_transformed)    │      (Calculates Profit, Shifts, Date Parts)
└────────────────┬────────────────┘
│
▼
┌─────────────────────────────────┐
│  Business Queries & Dashboards  │  <-- Executive Reports & BI Connectors
└─────────────────────────────────┘
### Calculated Field Logic in View
* **Calculated Profit:** `(price_per_unit - cogs) * quantity`
* **Normalized Profit Margin %:** 
  $$\text{Profit Margin \%} = \left( \frac{\sum ((\text{Price Per Unit} - \text{COGS}) \times \text{Quantity})}{\text{NULLIF}\left(\sum (\text{Total Sale}), 0\right)} \right) \times 100$$
* **Sales Shift Breakdown:** Categorizes transactions into `Morning`, `Afternoon`, or `Evening` using time-range conditional logic.

---

## 🔍 Data Integrity Audit 

Before performing business analysis, a dedicated audit phase was executed to validate data reliability:

* **Calculation Reconciliation:** Verified that `quantity * price_per_unit` strictly matched `total_sale`.
* **Business Logic Audit:** Flagged "Negative Margin" anomalies where COGS exceeded the sale price, identifying potential upstream data entry errors.
* **Null Value Handling:** Cleaned and verified dataset completeness to prevent calculation skews during aggregation.

---

## 📊 Deep Analysis & Core Business Findings

### 1. Category Profitability Efficiency
While **Electronics** brings in the highest gross dollar volume, **Beauty** delivers the highest profit margin per dollar earned:

Category      | Total Revenue  | Total Profit   | Profit Margin %
--------------+----------------+----------------+----------------
Beauty        | $286,790.00    | $137,441.80    | 47.92%  <-- Highest Efficiency
Clothing      | $309,995.00    | $143,236.30    | 46.21%
Electronics   | $311,445.00    | $140,690.85    | 45.17%


### 2. Time-Series & Shift Velocity
Analysis of order distribution across operational shifts reveals peak revenue windows:
* **Evening Shift:** 1,062 orders | **$475,940.00** total revenue | Avg ticket size: **$448.15**
* **Morning Shift:** 548 orders | **$256,410.00** total revenue | Avg ticket size: **$467.90**
* **Afternoon Shift:** 377 orders | **$175,880.00** total revenue | Avg ticket size: **$466.53**

---

## 📂 Files in this Repository

* 📄 [Retail_sales_analysis.sql](./Retail_sales_analysis.sql) — Complete SQL workflow including database setup, schema creation, data audit, virtual view creation, and business analysis queries.
* 📊 [SQL - Retail Sales Analysis_utf.csv](./SQL%20-%20Retail%20Sales%20Analysis_utf.csv) — Cleaned raw dataset imported into PostgreSQL.

---

## 👤 Author

**Saanchi Gupta**  
*Data Analytics Professional | Raebareli, India*  
Specializing in building reliable, audit-ready data solutions using SQL, Excel, and Business Intelligence tools.  
🔗 [LinkedIn](https://www.linkedin.com/in/sanchigupta21) | [GitHub](https://github.com/sanchi-111) 











To preserve source data immutability while creating pre-calculated metrics for downstream reporting, the pipeline routes all executive queries through a virtual view:
