-- 1
CREATE DATABASE advanced_lab;

CREATE TABLE IF NOT EXISTS employees (
    emp_id      SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    department  VARCHAR(50),
    salary      INT,
    hire_date   DATE,
    status      VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE IF NOT EXISTS departments (
    dept_id     SERIAL PRIMARY KEY,
    dept_name   VARCHAR(50) NOT NULL,
    budget      INT,
    manager_id  INT
);

CREATE TABLE IF NOT EXISTS projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id      INT,
    start_date   DATE,
    end_date     DATE,
    budget       INT
);

-- 2
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Alice', 'Johnson', 'Engineering');

-- 3
INSERT INTO employees VALUES (2 , 'John','SQL', 'Engineering', DEFAULT, '2024-01-10', DEFAULT);

-- 4
INSERT INTO departments (dept_id, dept_name, budget, manager_id)
VALUES (1, 'Engineering', 500000, NULL),
       (2, 'Marketing',   200000, NULL),
       (3, 'HR',          150000, NULL);
-- 5
INSERT INTO employees
VALUES (10, 'Nathan', 'Filmont', 'IT', 50000*1.1, CURRENT_DATE, DEFAULT);

-- 6
CREATE TEMPORARY TABLE temp_employees (
    emp_id      INT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    department  VARCHAR(50),
    salary      INT,
    hire_date   DATE,
    status      VARCHAR(20)
);
INSERT INTO temp_employees SELECT * FROM employees WHERE department = 'IT';

-- 7
UPDATE employees SET salary = salary*1.1;

-- 8
UPDATE employees SET status = 'Senior' WHERE salary > 60000 AND employees.hire_date < '2020-01-01';

-- 9
UPDATE employees SET department =
CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10
UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';

-- 11
UPDATE departments SET budget = (SELECT ROUND(AVG(salary) * 1.2) FROM employees WHERE department = departments.dept_name);

-- 12
UPDATE employees SET salary = salary * 1.15, status = 'Promoted' WHERE department = 'Sales';

-- 13
DELETE FROM employees WHERE status = 'Terminated';

-- 14
DELETE FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND  department IS NULL;

-- 15
DELETE FROM departments WHERE dept_name NOT IN ( SELECT DISTINCT department FROM employees WHERE department IS NOT NULL);
-- 16
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

-- 17
INSERT INTO employees VALUES (12, 'Jog',  'Makarov', NULL, NULL, '2024-01-10', DEFAULT);

-- 18
UPDATE employees SET  department = 'Unassigned' WHERE department IS NULL;

-- 19
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

-- 20
INSERT INTO employees VALUES(15, 'Kirill',  'Makarov', 'IT', 100000, '2024-12-10', DEFAULT) RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21
UPDATE employees SET salary = salary + 5000 WHERE department = 'IT' RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- 22
DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

-- 23
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date)
SELECT 17, 'John', 'SQL', 'IT', 1200000, '2019-01-10'
WHERE NOT EXISTS ( SELECT 1 FROM employees WHERE first_name = 'John' AND last_name = 'SQL' );

-- 24
UPDATE employees e SET salary =
CASE
    WHEN d.budget > 100000 THEN salary*1.1
    ELSE salary*1.05
END
FROM departments d WHERE dept_name = e.department;

-- 25
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES
    (21, 'Ivan',  'Petrov',   'IT',        70000, '2024-01-10', 'Active'),
    (22, 'Olga',  'Smirnova', 'IT',        68000, '2024-01-11', 'Active'),
    (23, 'Sergey','Kuznetsov','IT',        72000, '2024-01-12', 'Active'),
    (24, 'Anna',  'Volkova',  'IT',        65000, '2024-01-13', 'Active'),
    (25, 'Dmitry','Sokolov',  'IT',        80000, '2024-01-14', 'Active');
UPDATE employees
SET salary = ROUND(salary * 1.10)
WHERE emp_id BETWEEN 21 AND 25;

-- 26
CREATE TABLE IF NOT EXISTS employees_archive (
    emp_id      SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    department  VARCHAR(50),
    salary      INT,
    hire_date   DATE,
    status      VARCHAR(20) DEFAULT 'Active'
);
INSERT INTO employees_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';

-- 27
UPDATE projects p SET end_date = end_date + 30 WHERE budget > 50000 AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;