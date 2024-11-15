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

