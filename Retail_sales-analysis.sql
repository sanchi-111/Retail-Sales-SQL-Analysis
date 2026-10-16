--- Project : Retail Sales Analysis & Integrity Audit
-- Author: Sanchi Gupta
-- PHASE 1: Core Schema Setup

CREATE DATABASE sql_project_p2;

DROP TABLE IF EXISTS retail_Sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit NUMERIC(10,2),
    cogs NUMERIC(10,2),
    total_sale NUMERIC(10,2)
);

SELECT COUNT(*) FROM retail_sales
/* PHASE 2: Data Cleaning & Scrubbing Audit */

-- Step A: Identify and remove records with missing essential values
DELETE FROM retail_sales
WHERE sale_date IS NULL 
   OR sale_time IS NULL 
   OR customer_id IS NULL 
   OR gender IS NULL 
   OR age IS NULL 
   OR category IS NULL 
   OR quantity IS NULL 
   OR price_per_unit IS NULL 
   OR cogs IS NULL 
   OR total_sale IS NULL;


---Phase 3 : Virtual Transformation (Creating View)

CREATE OR REPLACE VIEW retail_sales_transformed AS 
WITH sales_base AS (
   SELECT 
       transactions_id,
       sale_date,
       sale_time,
       EXTRACT(YEAR FROM sale_date) AS sale_year,
       EXTRACT(MONTH FROM sale_date) AS sale_month,
       TO_CHAR(sale_date, 'YYYY-MM') AS year_month,
       customer_id,
       gender,
       age,
       category,
       quantity,
       price_per_unit,
       cogs,
       total_sale,
       (price_per_unit - cogs) * quantity AS calculated_profit,
       CASE 
           WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
           WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
	   END AS sales_shift
    FROM retail_sales
  )
   SELECT  
       *,
	   -- Operational Status Logic Gate
	   CASE
	      WHEN total_sale > 1000 THEN 'High_Value_TRANSACTION'
		  WHEN calculated_profit < 0 THEN 'Margin_Leakage_RISK'
		  ELSE 'STANDARD_TRANSACTION'
	   END AS operational_status
  FROM sales_base;	   

--Verification

  SELECT * FROM  retail_sales_transformed LIMIT 20

 /* Phase 4: 
--Q-1- Advanced Business Query: Profit Margin Analysis across Categories
-- Business Purpose: Identify categories operating on dangerously thin profit margins.
-- Finding: Quantifies gross profit margin percentage per category.
-- Recommendation: Adjust pricing strategies or renegotiate vendor COGS for low-margin items.*/

 SELECT 
     category,
	 SUM(total_sale) AS total_revenue,
	 SUM((price_per_unit - cogs) * quantity) AS total_profit,
	 ROUND
	 ((SUM((price_per_unit - cogs) * quantity) / NULLIF(SUM(total_sale), 0)) * 100,
	  2 ) as profit_margin_perc
 FROM retail_sales_transformed
 GROUP BY category
 ORDER BY profit_margin_perc

------------------------------------------------------------------------------------------------------

-- Q2: Peak Season Category Revenue Velocity (Nov vs Oct Performance)
-- Business Purpose: Measure demand surge per category during peak quarter promotional events.
-- Finding: Quantifies revenue increase across product lines during peak holiday shopping.
-- Recommendation: Prioritize warehouse replenishment for fast-moving categories before peak months.

SELECT 
  category,
  SUM(CASE WHEN year_month = '2022-10' THEN total_sale ELSE 0 END) AS oct_revenue,
  SUM(CASE WHEN year_month = '2022-11' THEN total_sale ELSE 0 END) AS nov_revenue,
     ROUND(((SUM(CASE WHEN year_month = '2022-11' THEN total_sale ELSE 0 END) - 
	    SUM(CASE WHEN year_month = '2022-10' THEN total_sale ELSE 0 END) /
     NULLIF(SUM(CASE WHEN year_month = '2022-10' THEN total_sale ELSE 0 END),0)) *100),2
	 ) AS nov_growth_perc
	 FROM retail_sales_transformed
	 GROUP BY category
	 ORDER BY nov_growth_perc desc
  
-----------------------------------------------------------------------------------------------------

-- Q3- Comprehensive Category Revenue & Customer Penetration Benchmark
-- Business Purpose: Evaluate total revenue, active customer reach, and average order value per category.
-- Finding: Ranks categories by financial contribution and customer acquisition efficiency.
-- Recommendation: Focus high-value customer acquisition campaigns on top AOV categories.

    SELECT 
	     category,
		 COUNT(DISTINCT customer_id) AS unique_customers,
		 COUNT(*) AS total_orders,
		 SUM(total_sale) AS net_revenue,
		  ROUND(AVG(total_sale),2) AS avg_order_value
   FROM retail_sales_transformed
   GROUP BY category
   ORDER BY net_revenue DESC

 ----------------------------------------------------------------------------------

-- Q4: VIP Customer Recency & Churn Risk (RFM Analytics)
-- Business Purpose: Monitor purchase recency for high-value customers to prevent customer churn.
-- Finding: Identifies top spenders who have not placed orders recently.
-- Recommendation: Trigger targeted re-engagement offers to inactive VIP accounts.

 SELECT 
    customer_id,
	COUNT(transactions_id) AS frequency_ordeers,
	SUM(total_sale) AS monetary_value,
	MAX(sale_date) AS last_purchase_date,
	CURRENT_DATE - MAX(sale_date) AS recency_days
 FROM retail_sales_transformed
 GROUP BY customer_id
 HAVING SUM(total_sale) > 2000
 ORDER BY recency_days DESC

----------------------------------------------------------------

-- Q5: Month-over-Month (MoM) Revenue Growth Rate Tracking
-- Business Purpose: Measure business expansion velocity and detect demand slowdowns early.
-- Finding: Calculates percentage change in net sales month-over-month using LAG() window functions.
-- Recommendation: Investigate negative growth periods to resolve operational bottlenecks.

WITH monthly_revenue AS (
    SELECT 
        year_month,
        SUM(total_sale) AS current_month_sales
    FROM retail_sales_transformed
    GROUP BY year_month
)
SELECT 
    year_month,
    current_month_sales,
    LAG(current_month_sales, 1) OVER (ORDER BY year_month) AS previous_month_sales,
    ROUND(
        ((current_month_sales - LAG(current_month_sales, 1) OVER (ORDER BY year_month)) 
        / NULLIF(LAG(current_month_sales, 1) OVER (ORDER BY year_month), 0)) * 100, 
        2
    ) AS mom_growth_perc
FROM monthly_revenue;

-----------------------------------------------------------------------------------------------------

-- Q6 -- Calculate total transaction count by gender across each product category
-- Business Purpose: Map product category preference by customer demographic segments.
-- Finding: Reveals category purchase frequency breakdowns across male and female shoppers.
-- Recommendation: Adjust visual merchandising layouts according to demographic preferences.


 SELECT 
    category,
    gender,
    COUNT(*) AS total_trans_count
 FROM retail_sales_transformed
 GROUP BY category, gender
 ORDER BY category, gender;

----------------------------------------------------------------------------------------------------

-- Q7 -- Determine peak sales months per year using window ranking functions
-- Business Purpose: Isolate top-performing revenue months per calendar year.
-- Finding: Identifies seasonal revenue peaks and year-over-year shifts.
-- Recommendation: Prepare inventory supply chains ahead of historic peak demand months.

WITH monthly_sales AS (
    SELECT 
        sale_year,
        sale_month,
        ROUND(AVG(total_sale), 2) AS avg_sale,
        RANK() OVER(PARTITION BY sale_year ORDER BY AVG(total_sale) DESC) AS sales_rank
    FROM retail_sales_transformed
    GROUP BY sale_year, sale_month
)
SELECT 
    sale_year,
    sale_month,
    avg_sale
FROM monthly_sales
WHERE sales_rank = 1;

------------------------------------------------------------------------------------------------

-- Q8: Cross-Category Customer Purchasing Penetration
-- Business Purpose: Evaluate cross-category adoption to measure effective cross-selling.
-- Finding: Segments customers into single-category vs. multi-category buyers.
-- Recommendation: Design bundled offers for single-category buyers to increase average basket size.

WITH customer_category_count AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT category) AS categories_bought
    FROM retail_sales_transformed
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN categories_bought = 1 THEN 'Single-Category Buyer'
        WHEN categories_bought = 2 THEN 'Dual-Category Buyer'
        ELSE 'Multi-Category Loyalist'
    END AS customer_segment,
    COUNT(customer_id) AS total_customers,
    ROUND(COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER(), 2) AS customer_perc
FROM customer_category_count
GROUP BY categories_bought;

---------------------------------------------------------------------------------------------------

-- Q9 -- Count the number of unique customers who purchased items from each category
-- Business Purpose: Evaluate customer reach and penetration across product lines.
-- Finding: Displays distinct customer count actively buying in each category.
-- Recommendation: Cross-sell adjacent categories to single-category customer segments.

SELECT 
    category,
    COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail_sales_transformed
GROUP BY category;

-------------------------------------------------------------------------------------------

-- Q10: Operational Shift Revenue Yield & Hourly Concentration
-- Business Purpose: Assess order volume and ticket size across operational shifts.
-- Finding: Quantifies revenue yield during Morning, Afternoon, and Evening shift windows.
-- Recommendation: Align store staffing schedules with high-volume operational shifts.

SELECT 
    sales_shift,
    COUNT(*) AS total_orders,
    SUM(total_sale) AS shift_revenue,
    ROUND(AVG(total_sale), 2) AS avg_ticket_size
FROM retail_sales_transformed
GROUP BY sales_shift
ORDER BY shift_revenue DESC;

------------------------ END OF PROJECT ----------------------------------------------------------
