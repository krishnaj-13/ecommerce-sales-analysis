/*
E-commerce Sales Analysis
Dataset: UK Online Retail
Objective: Analyze revenue trends, customer behavior, and product performance using SQL
*/

-- 1. Total Revenue (excluding returns)
SELECT 
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM online_retail
WHERE quantity > 0
  AND unit_price > 0;


-- 2. Monthly Revenue Trend
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    ROUND(SUM(quantity * unit_price), 2) AS monthly_revenue
FROM online_retail
WHERE quantity > 0
GROUP BY month
ORDER BY month;


-- 3. Month-over-Month Growth using LAG
WITH monthly_data AS (
    SELECT 
        DATE_FORMAT(invoice_date, '%Y-%m') AS month,
        SUM(quantity * unit_price) AS monthly_revenue
    FROM online_retail
    WHERE quantity > 0
    GROUP BY month
)
SELECT 
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        (
            (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
            / LAG(monthly_revenue) OVER (ORDER BY month)
        ) * 100
    , 2) AS growth_percentage
FROM monthly_data
ORDER BY month;


-- 4. Average Order Value (AOV)
SELECT 
    ROUND(
        SUM(quantity * unit_price) / COUNT(DISTINCT invoice_no)
    , 2) AS average_order_value
FROM online_retail
WHERE quantity > 0;


-- 5. Top 10 Customers by Revenue
SELECT 
    customer_id,
    ROUND(SUM(quantity * unit_price), 2) AS total_spent,
    RANK() OVER (ORDER BY SUM(quantity * unit_price) DESC) AS customer_rank
FROM online_retail
WHERE quantity > 0
GROUP BY customer_id
LIMIT 10;


-- 6. Revenue Contribution of Top 10 Customers
WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price) AS total_spent
    FROM online_retail
    WHERE quantity > 0
    GROUP BY customer_id
)
SELECT 
    ROUND(
        SUM(total_spent) /
        (SELECT SUM(quantity * unit_price)
         FROM online_retail
         WHERE quantity > 0) * 100
    , 2) AS top_10_percentage
FROM (
    SELECT total_spent
    FROM customer_revenue
    ORDER BY total_spent DESC
    LIMIT 10
) AS top_customers;


-- 7. Repeat vs One-Time Customers
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_no) AS order_count
    FROM online_retail
    WHERE quantity > 0
    GROUP BY customer_id
)
SELECT 
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM customer_orders;


-- 8. Churn Analysis (90-Day Inactivity)
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(invoice_date) AS last_order_date
    FROM online_retail
    WHERE quantity > 0
    GROUP BY customer_id
)
SELECT 
    COUNT(*) AS churned_customers
FROM last_purchase
WHERE last_order_date < DATE_SUB('2012-11-09', INTERVAL 90 DAY);


-- 9. Top 10 Products by Revenue
SELECT 
    stock_code,
    ROUND(SUM(quantity * unit_price), 2) AS product_revenue
FROM online_retail
WHERE quantity > 0
GROUP BY stock_code
ORDER BY product_revenue DESC
LIMIT 10;
