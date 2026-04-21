-- ============================================================
--  SALES BI PLATFORM — MySQL Schema
--  Tool : SQL Workbench
--  How  : Open SQL Workbench → paste everything → Ctrl+Shift+Enter
-- ============================================================

-- Create and select database
CREATE DATABASE IF NOT EXISTS sales_bi;
USE sales_bi;

-- Drop in correct order (fact first, then dims)
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;

-- ── Dimension: Date ───────────────────────────────────────
CREATE TABLE dim_date (
    date_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_date    DATE        NOT NULL UNIQUE,
    year         INT,
    quarter      INT,
    month        INT,
    month_name   VARCHAR(20),
    week         INT,
    day_of_week  VARCHAR(15)
);

-- ── Dimension: Product ────────────────────────────────────
CREATE TABLE dim_product (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category     VARCHAR(50),
    UNIQUE KEY uq_product (product_name, category)
);

-- ── Dimension: Customer ───────────────────────────────────
CREATE TABLE dim_customer (
    customer_id   VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    region        VARCHAR(50)
);

-- ── Fact Table: Sales ─────────────────────────────────────
CREATE TABLE fact_sales (
    sale_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id     VARCHAR(50)    UNIQUE,
    date_id      INT,
    product_id   INT,
    customer_id  VARCHAR(20),
    quantity     INT,
    unit_price   DECIMAL(10,2),
    sales_amount DECIMAL(12,2),
    discount     DECIMAL(5,2),
    net_revenue  DECIMAL(12,2),
    FOREIGN KEY (date_id)    REFERENCES dim_date(date_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id)REFERENCES dim_customer(customer_id)
);

-- ── Verify ────────────────────────────────────────────────
SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = 'sales_bi';

SELECT 'Schema ready!' AS status;
