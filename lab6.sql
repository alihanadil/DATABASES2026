CREATE DATABASE lab6;
-- Create table: employees
CREATE TABLE employees
(
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id  INT,
    salary   DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments
(
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects
(
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id      INT,
    budget       DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (1, 'John Smith', 101, 50000),
       (2, 'Jane Doe', 102, 60000),
       (3, 'Mike Johnson', 101, 55000),
       (4, 'Sarah Williams', 103, 65000),
       (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location)
VALUES (101, 'IT', 'Building A'),
       (102, 'HR', 'Building B'),
       (103, 'Finance', 'Building C'),
       (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
                      budget)
VALUES (1, 'Website Redesign', 101, 100000),
       (2, 'Employee Training', 102, 50000),
       (3, 'Budget Analysis', 103, 75000),
       (4, 'Cloud Migration', 101, 150000),
       (5, 'AI Research', NULL, 200000);

-- 2.1
SELECT e.emp_name, d.dept_name
FROM employees e
         CROSS JOIN departments d;
-- 20

-- 2.2
SELECT emp_name, dept_name
FROM employees,
     departments;
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON TRUE;

-- 2.3
SELECT e.emp_name, p.project_name
FROM employees e
         CROSS JOIN projects p;

-- 3.1
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4 rows, Tom dept is null

-- 3.2
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d USING (dept_id);
-- with USING, the join column appears only once in the result (merged), whereas with ON
-- it appears twice (once from each table). You don't see the difference here because
-- you only select emp_name and dept_name - but SELECT * would show it.

-- 3.3
SELECT e.emp_name, d.dept_name
FROM employees e
         NATURAL INNER JOIN departments d;

-- 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON d.dept_id = e.dept_id
         INNER JOIN projects p ON p.dept_id = d.dept_id;

-- 4.1
SELECT e.emp_id, e.emp_name, e.dept_id AS e_dept_id, d.dept_id AS d_dept_id, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom is departmentless

-- 4.2
SELECT emp_id, emp_name, dept_id, dept_name
FROM employees e
         LEFT JOIN departments d USING (dept_id);
-- 4.3
SELECT e.emp_id, e.emp_name, e.dept_id AS e_dept_id, d.dept_id AS d_dept_id, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
ORDER BY employee_count DESC;

-- 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- 5.3
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;
-- Tom on the right side, Marketing on the left

-- 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;

-- 6.3
SELECT CASE WHEN e.emp_id IS NULL THEN 'Department without employees'
            WHEN d.dept_id IS NULL THEN 'Employee without department'
            ELSE 'Matched' END AS record_status,
       e.emp_name,
       d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;

-- 7.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building C';

-- 7.2
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building C';
-- first query takes all the rows from employees since it is a left join, second query filters the rows that are made from join and selects only the ones that satisfy the condition

-- 7.3
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building C';
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building C';
-- the result now is the same as in query 2 since inner join shows only the rows that satisfy both conditions

-- 8.1
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id;

-- 8.2
ALTER TABLE employees
    ADD COLUMN manager_id INT;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 1;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 2;
UPDATE employees
SET manager_id = NULL
WHERE emp_id = 3;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 4;
UPDATE employees
SET manager_id = 3
WHERE emp_id = 5;

SELECT e1.emp_id, e1.emp_name, e2.emp_name
FROM employees e1
         LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;

-- 8.3
SELECT d.dept_name, AVG(e.salary) AS average_salary
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 50000
ORDER BY average_salary;