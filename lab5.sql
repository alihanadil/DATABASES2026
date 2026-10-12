-- Name: Adylkhanov Alikhan
-- Student ID: 25B030124

DROP TABLE IF EXISTS
    order_details, orders, products, customers, order_items, products_fk,
    categories, books, publishers, authors, employees_dept, student_courses,
    departments, course_enrollments, users, inventory, customers, bookings,
    products_catalog, employees
CASCADE;

-- 1.1
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- 1.2
CREATE TABLE products_catalog
(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
        )
);

-- 1.3
CREATE TABLE bookings
(
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE,
    check_out_date DATE CHECK ( check_out_date > check_in_date ),
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10)
);

-- 1.4
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (1, 'Alice', 'Smith', 30, 50000);
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (2, 'Bob', 'Jones', 45, 75000);
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (3, 'Charlie', 'Brown', 17, 40000); -- age < 18. fail
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (4, 'Dana', 'White', 30, 0); -- salary = 0. fail

INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (2, 'Mouse', 50, 40);
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (3, 'Phone', 300, 350); -- discount > regular. fail
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (4, 'Tablet', 0, 10); -- regular = 0. fail

INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (1, '2025-01-01', '2025-01-05', 2);
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (2, '2025-02-01', '2025-02-03', 4);
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (3, '2025-03-05', '2025-03-01', 2); -- in > out. fail
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (4, '2025-04-01', '2025-04-05', 11); -- num_guests > 10. fail

-- 2.1
CREATE TABLE customers
(
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- 2.2
CREATE TABLE inventory
(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK ( unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- 2.3
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
(1, 'alice@gmail.com', '9843315', '2025-03-12');
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
(2, 'bob@gmail.com', '9843316', '2025-03-13');
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (NULL, 'charlie@example.com', '555-9999', '2025-03-01'); -- customer_id null. fail
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (4, NULL, '555-9999', '2025-03-01'); -- email null. fail
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (5, 'dana@example.com', NULL, '2025-04-01'); -- phone nullable. ok

INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (1, 'Widget', 100, 9.99, '2025-01-01 10:00:00');
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (2, 'Gadget', 50, 19.99, '2025-01-02 10:00:00');
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (3, NULL, 50, 5.00, '2025-01-03 12:00:00'); -- item_name null. fail
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (4, 'Gizmo', 50, 5.00, NULL); -- last_updated null. fail
-- inventory has no nullable columns

-- 3.1
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);

-- 3.2
CREATE TABLE course_enrollments
(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

-- 3.3
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);
INSERT INTO users (user_id, username, email, created_at) VALUES
(1, 'Walter White', 'walterreal@gmail.com', '2024-12-12');
INSERT INTO users (user_id, username, email, created_at) VALUES
(2, 'Walter White', 'walternotreal@gmail.com', '2025-01-02'); -- dup username. fail
INSERT INTO users (user_id, username, email, created_at) VALUES
(3, 'jesse', 'walterreal@gmail.com', '2025-01-03'); -- dup email. fail

-- 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
INSERT INTO departments (dept_id, dept_name, location) VALUES
(1, 'Engineering', 'Building A'),
(2, 'Sales', 'Building B'),
(3, 'HR', 'Building C');
INSERT INTO departments (dept_id, dept_name, location)
VALUES (1, 'Marketing', 'Building D'); -- dup id. fail
INSERT INTO departments (dept_id, dept_name, location)
VALUES (NULL, 'Finance', 'Building E'); -- null id. fail

-- 4.2
CREATE TABLE student_courses
(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- 4.3
-- 1. PRIMARY KEY uniquely identifies each row and forbids NULLs, while a UNIQUE constraint also enforces uniqueness but allows NULL values and a table can have many of them.
-- 2. Use a single-column primary key when one column alone uniquely identifies each row, and use a composite primary key when uniqueness only exists in the combination of two or more columns (like student_id + course_id).
-- 3. A table can have only one PRIMARY KEY because it defines the single, main row identifier and cannot allow NULLs, whereas multiple UNIQUE constraints can coexist because they are just additional uniqueness rules that permit NULLs and don't define the row's primary identity.

-- 5.1
CREATE TABLE employees_dept
(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments (dept_id),
    hire_date DATE
);
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1, 'Alice Smith', 1, '2025-01-15');
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (2, 'Bob Jones', 2, '2025-01-20');
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (3, 'Charlie Brown', 99, '2025-02-01'); -- dept 99 missing. fail

-- 5.2
CREATE TABLE authors
(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers
(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books
(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors (author_id),
    publisher_id INTEGER REFERENCES publishers (publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);
INSERT INTO authors (author_id, author_name, country) VALUES
(1, 'George Orwell', 'United Kingdom'),
(2, 'J.K. Rowling', 'United Kingdom');
INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
(1, 'Secker & Warburg', 'London'),
(2, 'Bloomsbury', 'London');
INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
(1, 'Nineteen Eighty-Four', 1, 1, 1949, '978-0451524935'),
(2, 'Harry Potter', 2, 2, 1997, '978-0747532699');

-- 5.3
CREATE TABLE categories
(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk
(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories (category_id) ON DELETE RESTRICT
);
CREATE TABLE orders
(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items
(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk (product_id),
    quantity INTEGER CHECK ( quantity > 0 )
);

INSERT INTO categories (category_id, category_name) VALUES (1, 'Electronics');
INSERT INTO categories (category_id, category_name) VALUES (2, 'Books');
INSERT INTO products_fk (product_id, product_name, category_id) VALUES (1, 'Laptop', 1);
INSERT INTO products_fk (product_id, product_name, category_id) VALUES (2, 'Phone', 1);
INSERT INTO orders (order_id, order_date) VALUES (1, '2025-01-10');
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES (1, 1, 1, 2);
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES (2, 1, 2, 1);

-- RESTRICT: cannot delete category 1 while products still reference it.
DELETE FROM categories WHERE category_id = 1; -- ERROR

SELECT * FROM order_items; -- 2 rows
DELETE FROM orders WHERE order_id = 1; -- CASCADE removes order_items
SELECT * FROM order_items; -- 0 rows
-- order delete succeeds and order_items rows are removed because of ON DELETE CASCADE

-- 6.1
DROP TABLE IF EXISTS customers, products, orders, order_details CASCADE;
CREATE TABLE customers
(
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE products
(
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
CREATE TABLE orders
(
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
CREATE TABLE order_details
(
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products (product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers (customer_id, name, email, phone, registration_date) VALUES
(1, 'Alice Smith', 'alice@example.com', '555-1111', '2025-01-01'),
(2, 'Bob Jones', 'bob@example.com', '555-2222', '2025-01-05'),
(3, 'Charlie Brown', 'charlie@example.com', '555-3333', '2025-01-10'),
(4, 'Dana White', 'dana@example.com', NULL, '2025-02-01'),
(5, 'Eve Black', 'eve@example.com', '555-5555', '2025-02-15');

INSERT INTO products (product_id, name, description, price, stock_quantity) VALUES
(1, 'Laptop', '14-inch laptop', 1000, 50),
(2, 'Mouse', 'Wireless mouse', 25, 200),
(3, 'Keyboard', 'Mechanical keyboard', 75, 100),
(4, 'Monitor', '27-inch monitor', 300, 30),
(5, 'Headset', 'Noise-cancelling', 150, 0);

INSERT INTO orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2025-03-01', 1025, 'pending'),
(2, 2, '2025-03-02', 75, 'processing'),
(3, 3, '2025-03-03', 300, 'shipped'),
(4, 4, '2025-03-04', 150, 'delivered'),
(5, 5, '2025-03-05', 50, 'cancelled');

INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 1000),
(2, 1, 2, 1, 25),
(3, 2, 3, 1, 75),
(4, 3, 4, 1, 300),
(5, 4, 5, 1, 150);

SELECT * FROM customers; -- all rows
SELECT * FROM products WHERE stock_quantity = 0; -- Headset
SELECT COUNT(*) FROM orders WHERE status NOT IN ('pending','processing','shipped','delivered','cancelled'); -- 0

INSERT INTO customers (customer_id, name, email, phone, registration_date)
VALUES (6, 'Frank Green', 'alice@example.com', '555-6666', '2025-03-10'); -- dup email. fail
INSERT INTO products (product_id, name, description, price, stock_quantity)
VALUES (6, 'Tablet', '10-inch tablet', -100, 20); -- price < 0. fail
INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
VALUES (6, 1, '2025-03-11', 500, 'unknown'); -- bad status. fail
INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (6, 1, 1, 0, 1000); -- quantity = 0. fail

DELETE FROM customers WHERE customer_id = 1; -- cascades
SELECT * FROM orders WHERE customer_id = 1; -- 0 rows
SELECT * FROM order_details WHERE order_id = 1; -- 0 rows