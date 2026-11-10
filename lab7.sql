CREATE DATABASE lab7;
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
CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;
SELECT *
FROM employee_details;
-- 4 ROWS.  Tom has no department

-- 2.2
CREATE VIEW dept_statistics AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       AVG(e.salary)   AS average_salary,
       MAX(e.salary)   AS max_salary,
       MIN(e.salary)   AS min_salary
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;

-- 2.3
CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location, COUNT(e.emp_id) AS employee_count
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name, d.location;

-- 2.4
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE salary > 55000;
SELECT *
FROM high_earners;
-- Yes i can

-- 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name
     , e.salary
     , d.dept_name
     , d.location
     , CASE WHEN e.salary > 60000 THEN 'High' WHEN e.salary > 50000 THEN 'Medium' ELSE 'Standard' END AS salary_grade
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;
SELECT *
FROM employee_details;

-- 3.2
    ALTER VIEW high_earners RENAME TO top_performers;
SELECT *
FROM top_performers;

-- 3.3
CREATE TEMPORARY VIEW temp_view AS
SELECT emp_name
FROM employees
WHERE salary < 50000;
DROP VIEW temp_view;

-- 4,1
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

-- 4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
SELECT *
FROM employees
WHERE emp_name = 'John Smith';

-- 4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);
SELECT *
FROM employee_salaries;
-- YES

-- 4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- FAILS BECAUSE IT DOES NOT PASS THE LOCAL CHECK

-- 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COALESCE(e.employee_count, 0)       AS employee_count,
       COALESCE(e.total_salary, 0)         AS total_salary,
       COALESCE(p.project_count, 0)        AS project_count,
       COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
         LEFT JOIN ( SELECT dept_id, COUNT(*) AS employee_count, SUM(salary) AS total_salary
                     FROM employees
                     GROUP BY dept_id ) e ON e.dept_id = d.dept_id
         LEFT JOIN ( SELECT dept_id, COUNT(*) AS project_count, SUM(budget) AS total_project_budget
                     FROM projects
                     GROUP BY dept_id ) p ON p.dept_id = d.dept_id
WITH DATA;
SELECT *
FROM dept_summary_mv
ORDER BY employee_count DESC;

-- 5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;
-- now a the count for IT is 3

-- 5.3
CREATE UNIQUE INDEX dept_id_index ON dept_summary_mv (dept_id);
--  normal REFRESH MATERIALIZED VIEW takes an exclusive lock,
--  so SELECTs on the view block until the refresh finishes. CONCURRENTLY refreshes without blocking reads

-- 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name, p.budget, d.dept_name, COUNT(e.emp_id) AS employee_count
FROM projects p
         LEFT JOIN departments d ON p.dept_id = d.dept_id
         LEFT JOIN employees e ON p.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name
WITH NO DATA;
SELECT *
FROM project_stats_mv;
-- THE VIEW ISN'T POPULATED SO WE REFRESH
REFRESH MATERIALIZED VIEW project_stats_mv;

-- 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user PASSWORD 'report456';
SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';

-- 6.2
CREATE ROLE db_creator CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';

-- 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- 6.4
CREATE GROUP hr_team;
CREATE GROUP finance_team;
CREATE GROUP it_team;
CREATE USER hr_user1 PASSWORD 'hr001';
CREATE USER hr_user2 PASSWORD 'hr002';
CREATE USER finance_user1 PASSWORD 'fin001';
ALTER GROUP hr_team ADD USER hr_user1, hr_user2;
ALTER GROUP finance_team ADD USER finance_user1;
GRANT SELECT, UPDATE ON employees TO GROUP hr_team;
GRANT SELECT ON dept_statistics TO GROUP finance_team;

-- 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- 6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

-- 7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- 7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects
    OWNER TO project_manager;
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- 7.3
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table
(
    id INT
);
ALTER TABLE temp_table
    OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

-- 7.4
CREATE VIEW hr_employee_view AS
SELECT emp_name
FROM employees
WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;
CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- 8.1
CREATE VIEW dept_dashboard AS
SELECT d.dept_name,
       d.location,
       COALESCE(e.employee_count, 0)                                               AS employee_count,
       ROUND(COALESCE(e.avg_salary, 0), 2)                                         AS average_salary,
       COALESCE(p.active_project_count, 0)                                         AS active_projects,
       COALESCE(p.total_project_budget, 0)                                         AS total_project_budget,
       COALESCE(ROUND(p.total_project_budget / NULLIF(e.employee_count, 0), 2), 0) AS budget_per_employee
FROM departments d
         LEFT JOIN ( SELECT dept_id, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
                     FROM employees
                     GROUP BY dept_id ) e ON e.dept_id = d.dept_id
         LEFT JOIN ( SELECT dept_id, COUNT(*) AS active_project_count, SUM(budget) AS total_project_budget
                     FROM projects
                     -- If projects has a status column, add: WHERE status = 'active'
                     GROUP BY dept_id ) p ON p.dept_id = d.dept_id;
SELECT * FROM dept_dashboard ORDER BY employee_count DESC;

-- 8.2
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE                        'Standard Process'
       END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;
SELECT * FROM high_budget_projects ORDER BY budget DESC;

-- 8.3
-- Level 1: Viewer — read everything
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2: Entry — viewer + INSERT
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3: Analyst — entry + UPDATE
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4: Manager — analyst + DELETE
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice   PASSWORD 'alice123';
CREATE USER bob     PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';

GRANT viewer_role  TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;