-- =====================================================================
-- Retail Sales Analysis (SQL) | Sir Lim Data Solutions
-- Uchambuzi wa Mauzo ya Rejareja (SQL)
-- Database: retail_sales | Table: sales1_clean
-- Data: Jan-Jun 2024 | 500 orders / safu 500
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Setup: tengeneza database na table / Create database and table
--    Kisha ingiza Sales1_clean.csv (phpMyAdmin > Import, skip 1 line)
--    Then import Sales1_clean.csv (phpMyAdmin > Import, skip 1 line)
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

CREATE TABLE sales1_clean (
  order_id    INT PRIMARY KEY,
  order_date  DATE,
  product     VARCHAR(50),
  quantity    INT,
  branch      VARCHAR(50),
  price       DECIMAL(10,2),
  total_sales DECIMAL(12,2),
  month_num   INT,
  month_name  VARCHAR(20)
);


-- ---------------------------------------------------------------------
-- Ukaguzi wa data / Data check
-- Matokeo yanayotarajiwa / Expected: 500 rows, total 13,216,800
-- (inalingana na Pandas na Power BI / matches Pandas and Power BI)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM sales1_clean;
SELECT SUM(total_sales) AS total_sales FROM sales1_clean;


-- ---------------------------------------------------------------------
-- 1. Mauzo kwa tawi / Sales by branch
-- ---------------------------------------------------------------------
SELECT branch, SUM(total_sales) AS total_sales
FROM sales1_clean
GROUP BY branch
ORDER BY total_sales DESC;


-- ---------------------------------------------------------------------
-- 2. Mauzo na idadi kwa bidhaa / Sales and quantity by product
-- ---------------------------------------------------------------------
SELECT product,
       SUM(quantity)    AS total_quantity,
       SUM(total_sales) AS total_sales
FROM sales1_clean
GROUP BY product
ORDER BY total_sales DESC;


-- ---------------------------------------------------------------------
-- 3. Mauzo kwa mwezi / Sales by month
-- ---------------------------------------------------------------------
SELECT month_num, month_name, SUM(total_sales) AS total_sales
FROM sales1_clean
GROUP BY month_num, month_name
ORDER BY month_num;


-- ---------------------------------------------------------------------
-- 4. Wastani wa mauzo kwa oda / Average order value
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(total_sales), 2) AS avg_order_value
FROM sales1_clean;


-- ---------------------------------------------------------------------
-- 5. Bidhaa inayoongoza kila tawi / Top product per branch
-- ---------------------------------------------------------------------
WITH ranked AS (
  SELECT branch, product,
         SUM(total_sales) AS total_sales,
         ROW_NUMBER() OVER (
           PARTITION BY branch
           ORDER BY SUM(total_sales) DESC
         ) AS rnk
  FROM sales1_clean
  GROUP BY branch, product
)
SELECT branch, product, total_sales
FROM ranked
WHERE rnk = 1;


-- ---------------------------------------------------------------------
-- 6. Oda 5 kubwa kuliko zote / Top 5 largest orders
--    Kumbuka: oda kadhaa zina kiasi sawa (ties), kwa hiyo orodha
--    ya mwisho inaweza kutofautiana kidogo.
--    Note: several orders share the same amount (ties), so the
--    last rows of the list may vary slightly.
-- ---------------------------------------------------------------------
SELECT order_id, order_date, product, branch, total_sales
FROM sales1_clean
ORDER BY total_sales DESC
LIMIT 5;
