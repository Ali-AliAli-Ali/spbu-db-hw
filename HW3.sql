-- 1


INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 3, 25, '2024-11-09'),
    (2, 3, 13, '2024-11-10'),
    (3, 3, 1, '2024-11-10'),
    (3, 2, 5, '2024-11-10'),
    (4, 1, 8, '2024-11-11'),
    (2, 1, 12, '2024-11-13');


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



