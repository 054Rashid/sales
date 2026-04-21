-- ============================================================
--  VERIFICATION QUERIES — Run in SQL Workbench after ETL
--  These confirm your data loaded correctly before Power BI
-- ============================================================

USE sales_bi;

-- 1. Row counts in all tables
SELECT 'dim_date'     AS tbl, COUNT(*) AS rows FROM dim_date     UNION ALL
SELECT 'dim_product'  AS tbl, COUNT(*) AS rows FROM dim_product  UNION ALL
SELECT 'dim_customer' AS tbl, COUNT(*) AS rows FROM dim_customer UNION ALL
SELECT 'fact_sales'   AS tbl, COUNT(*) AS rows FROM fact_sales;

-- 2. Total revenue and orders
SELECT
    COUNT(*)                        AS total_orders,
    ROUND(SUM(net_revenue), 2)      AS total_revenue,
    ROUND(AVG(net_revenue), 2)      AS avg_order_value,
    ROUND(AVG(discount)*100, 1)     AS avg_discount_pct,
    SUM(quantity)                   AS total_units_sold
FROM fact_sales;

-- 3. Revenue by region
SELECT
    c.region,
    COUNT(f.sale_id)                AS orders,
    ROUND(SUM(f.net_revenue), 2)    AS revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.region
ORDER BY revenue DESC;

-- 4. Revenue by category
SELECT
    p.category,
    COUNT(f.sale_id)                AS orders,
    ROUND(SUM(f.net_revenue), 2)    AS revenue,
    ROUND(AVG(f.net_revenue), 2)    AS avg_order
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Monthly revenue trend
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(f.sale_id)                AS orders,
    ROUND(SUM(f.net_revenue), 2)    AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- 6. Top 10 products
SELECT
    p.product_name,
    p.category,
    COUNT(f.sale_id)                AS orders,
    ROUND(SUM(f.net_revenue), 2)    AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- 7. Revenue by region AND category (for Power BI heatmap)
SELECT
    c.region,
    p.category,
    ROUND(SUM(f.net_revenue), 2)    AS revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product  p ON f.product_id  = p.product_id
GROUP BY c.region, p.category
ORDER BY c.region, revenue DESC;
