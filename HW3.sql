-- 1


INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 3, 25, '2024-11-09'),
    (2, 3, 13, '2024-11-10'),
    (3, 3, 1, '2024-11-10'),
    (3, 2, 5, '2024-11-10'),
    (4, 1, 8, '2024-11-11'),
    (2, 1, 12, '2024-11-13'),
    (2, 4, 25, '2024-11-13');


CREATE TEMP TABLE high_sales_products AS
    WITH last_sales_products AS (
        SELECT product_id, SUM(quantity) AS total_sales
            FROM sales
            WHERE sale_date >= CURRENT_DATE-7
        GROUP BY product_id
        ORDER BY product_id
    )
    SELECT * FROM last_sales_products 
        WHERE total_sales >= 10;

SELECT * FROM high_sales_products LIMIT 10;


-- 2


WITH employee_sales_stats AS (
    SELECT employees.employee_id, employees.name, 
        SUM(sales.quantity) AS sum_sales,
        AVG(sales.quantity) AS avg_sales
            FROM employees
            JOIN sales ON employees.employee_id = sales.employee_id
            WHERE employees.position LIKE 'Sales%' AND sales.sale_date >= CURRENT_DATE-30
        GROUP BY employees.employee_id
)
SELECT * FROM employee_sales_stats
    WHERE avg_sales >= (
        SELECT AVG(sales.quantity) FROM sales
            WHERE sale_date >= CURRENT_DATE-30
    )
    LIMIT 10;


-- 3


WITH employee_hierarchy AS (
    SELECT e1.employee_id AS manager_id, e1.name AS manager, 
        e2.employee_id AS employee_id, e2.name AS employee
        FROM employees e1
        JOIN employees e2 ON e1.employee_id = e2.manager_id
)
SELECT employee_id, employee FROM employee_hierarchy 
    WHERE manager_id = 1
LIMIT 10;


-- 4


WITH last_sales_products AS (
        SELECT product_id, SUM(quantity) AS total_sales, date_part('month', sale_date)::INT AS sale_month
            FROM sales
            WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE - INTERVAL'1 month') OR date_part('month', sale_date) = date_part('month', CURRENT_DATE)
        GROUP BY sale_month, product_id
        ORDER BY total_sales DESC  
    )
(
    SELECT * FROM last_sales_products 
        WHERE sale_month = date_part('month', CURRENT_DATE - INTERVAL'1 month')
    LIMIT 3
)
UNION
(
    SELECT * FROM last_sales_products 
        WHERE sale_month = date_part('month', CURRENT_DATE)
    LIMIT 3
)
ORDER BY sale_month, total_sales DESC;


-- 5


INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (4, 4, 25, '2024-11-13'),
    (2, 3, 13, '2024-11-14'),
    (3, 3, 20, '2024-11-14'),
    (3, 2, 5, '2024-11-14'),
    (4, 1, 8, '2024-11-14'),
    (2, 1, 2, '2024-11-14'),
    (2, 4, 5, '2024-11-15'),
    (3, 2, 15, '2024-11-15'),
    (4, 1, 18, '2024-11-15'),
    (2, 1, 22, '2024-11-15'),
    (2, 4, 35, '2024-11-15'),
    (1, 1, 2, '2024-11-15'),
    (2, 1, 10, '2024-11-15'),
    (3, 4, 3, '2024-11-15'),
    (3, 2, 5, '2024-11-15'),
    (4, 1, 8, '2024-11-15'),
    (2, 4, 20, '2024-11-15'),
    (2, 4, 5, '2024-11-15'),
    (3, 2, 15, '2024-11-15'),
    (4, 1, 18, '2024-11-15'),
    (2, 1, 22, '2024-11-15'),
    (2, 4, 35, '2024-11-15');


EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_sales FROM sales
    GROUP BY product_id
    ORDER BY product_id
LIMIT 20;

-- Planning Time: 0.157 ms
-- Execution Time: 0.162 ms

CREATE INDEX idx_department ON employees(department);
CREATE INDEX idx_sale_date ON sales(sale_date);

EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_sales FROM sales
    GROUP BY product_id
    ORDER BY product_id
LIMIT 20;

-- Planning Time: 1.651 ms
-- Execution Time: 0.090 ms

-- DROP INDEX idx_department, idx_sale_date;


-- 6


EXPLAIN
SELECT product_id, SUM(quantity) AS total_sales FROM sales
    GROUP BY product_id
    ORDER BY product_id
LIMIT 20;

-- Limit  (cost=2.25..2.60 rows=20 width=12)
--   ->  GroupAggregate  (cost=2.25..2.86 rows=35 width=12)
--       Group Key: product_id
--         ->  Sort  (cost=2.25..2.34 rows=35 width=8)
--             Sort Key: product_id
--               ->  Seq Scan on sales  (cost=0.00..1.35 rows=35 width=8)
