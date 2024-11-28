-- 1,3


CREATE OR REPLACE FUNCTION warning_correct_position()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT NEW.position = ANY(
        ARRAY(SELECT DISTINCT position FROM employees)
    ) THEN
        RAISE WARNING 'The position is not presented in the employees list. Please check your spelling and correct position if needed.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER warning_correct_position_trigger
    BEFORE INSERT OR UPDATE ON employees
    FOR EACH ROW
EXECUTE FUNCTION warning_correct_position();


SELECT * FROM employees LIMIT 20;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('George Washington', 'Tester', 'QA', 30000, 7);

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Harry Harris', 'Toster', 'QA', 35000, 7),
    ('Irina Reeves', 'Tester', 'QA', 35000, 7),
    ('James Jarvis', 'TesteR', 'QA', 35000, 7);
UPDATE employees
    SET position = 'Tester'
    WHERE position = 'Toster' OR position = 'TesteR';



CREATE OR REPLACE FUNCTION recalc_sum_salaries()
RETURNS TRIGGER AS $$
BEGIN
    CREATE OR REPLACE VIEW sum_salaries AS
        SELECT department, SUM(salary) AS sum_salary FROM employees
            GROUP BY department
            ORDER BY department;
    RAISE NOTICE 'New salaries sums are calculated and updated in view "sum_salaries".';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_sum_salaries_trigger
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH STATEMENT
EXECUTE FUNCTION recalc_sum_salaries();


INSERT INTO employees (employee_id, name, position, department, salary)
VALUES
    (14, 'Kain Keenetic', 'Developer', 'IT', 35000),
    (15, 'Liza Valley', 'Intern', 'IT', 20000),
    (16, 'Monika Gates', 'Manager', 'PR', 120000),
    (17, 'Nick Travis', 'Intern', 'PR', 20000, 16);
SELECT * FROM sum_salaries LIMIT 10;

UPDATE employees
    SET position = 'Manager'
    WHERE name = 'Kain Keenetic';
SELECT * FROM sum_salaries LIMIT 10;



CREATE VIEW employees_sales AS
    SELECT employees.name AS employee_name, 
           products.name AS product_name, 
           SUM(sales.quantity) AS total_sales
        FROM employees JOIN 
            sales ON employees.employee_id=sales.employee_id JOIN
            products ON sales.product_id=products.product_id
        GROUP BY employees.employee_id, products.name
        ORDER BY employees.employee_id;
SELECT * FROM employees_sales;


CREATE OR REPLACE FUNCTION update_sales()
RETURNS TRIGGER AS $$
BEGIN
    RAISE LOG 'Adding new row to table "sales".';
    INSERT INTO sales(employee_id, product_id, quantity, sale_date) VALUES
        (
            (SELECT employee_id FROM employees 
                WHERE name=NEW.employee_name),
            (SELECT product_id FROM products
                WHERE name=NEW.product_name),
            NEW.total_sales, 
            CURRENT_DATE
        );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_sales_trigger
    INSTEAD OF INSERT ON employees_sales
    FOR EACH ROW
    EXECUTE FUNCTION update_sales();

INSERT INTO employees_sales VALUES
    ('Alice Johnson', 'Product D', 3);
INSERT INTO employees_sales VALUES
    ('Alice Johnson', 'Product D', 5);
INSERT INTO employees_sales VALUES
    ('James Jarvis', 'Product A', 3);
SELECT * FROM employees_sales;

-- SELECT tgname FROM pg_trigger WHERE tgrelid = 'employees'::regclass;
-- DROP TRIGGER trigger_update_salary ON employees;



