-- Denormalized E-commerce Database Schema (No Joins Required)
-- All tables contain complete information with names - no joins needed

-- Drop existing tables if they exist (in reverse order due to foreign keys)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Table 1: Customers (Enhanced with order information)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL,
    age INTEGER,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    last_order_date DATE,
    favorite_category VARCHAR(50),
    customer_status VARCHAR(20) DEFAULT 'Active'
);

-- Table 2: Products (Enhanced with sales information)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    category_description VARCHAR(200),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    supplier VARCHAR(100),
    supplier_country VARCHAR(50),
    created_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    total_sold INTEGER DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0.00
);

-- Table 3: Orders (Enhanced with customer and product names)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_name VARCHAR(100) NOT NULL,
    customer_id INTEGER,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_country VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_country VARCHAR(50),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20) DEFAULT 'Completed',
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    items_count INTEGER DEFAULT 1,
    main_category VARCHAR(50)
);

-- Table 4: Order Items (Completely denormalized with all names)
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    order_name VARCHAR(100) NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    customer_id INTEGER,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_country VARCHAR(50) NOT NULL,
    product_id INTEGER,
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    supplier_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) DEFAULT 0.00,
    payment_method VARCHAR(30) NOT NULL
);

-- Insert sample data into customers
INSERT INTO customers (first_name, last_name, full_name, email, registration_date, country, age, total_spent, total_orders, last_order_date, favorite_category, customer_status) VALUES
('John', 'Smith', 'John Smith', 'john.smith@email.com', '2024-01-15', 'USA', 32, 1250.00, 2, '2024-03-07', 'Electronics', 'VIP'),
('Emma', 'Johnson', 'Emma Johnson', 'emma.johnson@email.com', '2024-02-20', 'Canada', 28, 890.50, 1, '2024-03-02', 'Food & Beverage', 'Active'),
('Carlos', 'Rodriguez', 'Carlos Rodriguez', 'carlos.rodriguez@email.com', '2024-01-30', 'Mexico', 35, 2100.75, 1, '2024-03-03', 'Sports & Fitness', 'VIP'),
('Sophie', 'Martin', 'Sophie Martin', 'sophie.martin@email.com', '2024-03-10', 'France', 29, 750.25, 1, '2024-03-04', 'Home & Garden', 'Active'),
('Yuki', 'Tanaka', 'Yuki Tanaka', 'yuki.tanaka@email.com', '2024-02-05', 'Japan', 26, 1580.00, 1, '2024-03-05', 'Sports & Fitness', 'Premium'),
('Maria', 'Silva', 'Maria Silva', 'maria.silva@email.com', '2024-01-25', 'Brazil', 31, 920.80, 1, '2024-03-06', 'Sports & Fitness', 'Active'),
('David', 'Wilson', 'David Wilson', 'david.wilson@email.com', '2024-03-15', 'UK', 42, 1650.30, 1, '2024-03-08', 'Electronics', 'Premium'),
('Anna', 'Kowalski', 'Anna Kowalski', 'anna.kowalski@email.com', '2024-02-28', 'Poland', 24, 560.90, 1, '2024-03-09', 'Electronics', 'New'),
('Ahmed', 'Hassan', 'Ahmed Hassan', 'ahmed.hassan@email.com', '2024-01-20', 'Egypt', 38, 1320.45, 1, '2024-03-10', 'Sports & Fitness', 'VIP'),
('Lisa', 'Anderson', 'Lisa Anderson', 'lisa.anderson@email.com', '2024-03-05', 'Australia', 33, 980.60, 0, NULL, 'Sports & Fitness', 'New');

-- Insert sample data into products
INSERT INTO products (product_name, category, category_description, price, stock_quantity, supplier, supplier_country, created_date, is_active, total_sold, total_revenue) VALUES
('Wireless Headphones', 'Electronics', 'Audio and Electronic Devices', 89.99, 150, 'TechCorp', 'China', '2024-01-01', true, 3, 269.97),
('Organic Coffee Beans', 'Food & Beverage', 'Organic Food and Beverages', 24.99, 200, 'CoffeeCo', 'Colombia', '2024-01-05', true, 3, 74.97),
('Yoga Mat', 'Sports & Fitness', 'Fitness and Sports Equipment', 35.50, 75, 'FitGear', 'India', '2024-01-10', true, 1, 35.50),
('Smartphone Case', 'Electronics', 'Mobile Phone Accessories', 15.99, 300, 'TechCorp', 'China', '2024-01-15', true, 2, 31.98),
('Ceramic Mug', 'Home & Garden', 'Kitchen and Home Accessories', 12.99, 120, 'HomeWare', 'Portugal', '2024-01-20', true, 3, 38.97),
('Running Shoes', 'Sports & Fitness', 'Athletic Footwear', 129.99, 60, 'SportsBrand', 'Vietnam', '2024-02-01', true, 4, 519.96),
('Laptop Stand', 'Electronics', 'Office and Computer Accessories', 45.00, 80, 'OfficeSupply', 'Taiwan', '2024-02-05', true, 2, 90.00),
('Green Tea', 'Food & Beverage', 'Organic Teas and Infusions', 18.50, 180, 'CoffeeCo', 'Japan', '2024-02-10', true, 2, 37.00),
('Desk Lamp', 'Home & Garden', 'Home Office Lighting', 55.99, 40, 'HomeWare', 'Germany', '2024-02-15', true, 3, 167.97),
('Protein Powder', 'Sports & Fitness', 'Nutritional Supplements', 79.99, 90, 'NutritionPlus', 'USA', '2024-02-20', true, 1, 79.99);

-- Insert sample data into orders
INSERT INTO orders (order_name, customer_id, customer_name, customer_email, customer_country, order_date, order_status, total_amount, shipping_country, payment_method, payment_status, discount_amount, items_count, main_category) VALUES
('Order #ORD-001', 1, 'John Smith', 'john.smith@email.com', 'USA', '2024-03-01', 'Completed', 105.48, 'USA', 'Credit Card', 'Completed', 5.50, 2, 'Electronics'),
('Order #ORD-002', 2, 'Emma Johnson', 'emma.johnson@email.com', 'Canada', '2024-03-02', 'Completed', 67.48, 'Canada', 'PayPal', 'Completed', 2.50, 3, 'Food & Beverage'),
('Order #ORD-003', 3, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', 'Mexico', '2024-03-03', 'Processing', 189.97, 'Mexico', 'Credit Card', 'Processing', 0.00, 3, 'Sports & Fitness'),
('Order #ORD-004', 4, 'Sophie Martin', 'sophie.martin@email.com', 'France', '2024-03-04', 'Completed', 43.48, 'France', 'Bank Transfer', 'Completed', 1.50, 3, 'Home & Garden'),
('Order #ORD-005', 5, 'Yuki Tanaka', 'yuki.tanaka@email.com', 'Japan', '2024-03-05', 'Shipped', 234.97, 'Japan', 'Credit Card', 'Completed', 10.00, 3, 'Sports & Fitness'),
('Order #ORD-006', 6, 'Maria Silva', 'maria.silva@email.com', 'Brazil', '2024-03-06', 'Completed', 91.99, 'Brazil', 'PayPal', 'Completed', 3.00, 2, 'Sports & Fitness'),
('Order #ORD-007', 1, 'John Smith', 'john.smith@email.com', 'USA', '2024-03-07', 'Processing', 55.99, 'USA', 'Credit Card', 'Processing', 0.00, 1, 'Home & Garden'),
('Order #ORD-008', 7, 'David Wilson', 'david.wilson@email.com', 'UK', '2024-03-08', 'Completed', 175.48, 'UK', 'Credit Card', 'Completed', 5.00, 3, 'Electronics'),
('Order #ORD-009', 8, 'Anna Kowalski', 'anna.kowalski@email.com', 'Poland', '2024-03-09', 'Cancelled', 0.00, 'Poland', 'PayPal', 'Cancelled', 0.00, 2, 'Electronics'),
('Order #ORD-010', 9, 'Ahmed Hassan', 'ahmed.hassan@email.com', 'Egypt', '2024-03-10', 'Shipped', 314.96, 'Egypt', 'Bank Transfer', 'Completed', 15.00, 3, 'Sports & Fitness');

-- Insert sample data into order_items
INSERT INTO order_items (order_id, order_name, order_date, order_status, customer_id, customer_name, customer_email, customer_country, product_id, product_name, product_category, supplier_name, quantity, unit_price, total_price, discount_applied, payment_method) VALUES
-- Order 1
(1, 'Order #ORD-001', '2024-03-01', 'Completed', 1, 'John Smith', 'john.smith@email.com', 'USA', 1, 'Wireless Headphones', 'Electronics', 'TechCorp', 1, 89.99, 89.99, 4.50, 'Credit Card'),
(1, 'Order #ORD-001', '2024-03-01', 'Completed', 1, 'John Smith', 'john.smith@email.com', 'USA', 4, 'Smartphone Case', 'Electronics', 'TechCorp', 1, 15.99, 15.99, 1.00, 'Credit Card'),
-- Order 2
(2, 'Order #ORD-002', '2024-03-02', 'Completed', 2, 'Emma Johnson', 'emma.johnson@email.com', 'Canada', 2, 'Organic Coffee Beans', 'Food & Beverage', 'CoffeeCo', 2, 24.99, 49.98, 2.00, 'PayPal'),
(2, 'Order #ORD-002', '2024-03-02', 'Completed', 2, 'Emma Johnson', 'emma.johnson@email.com', 'Canada', 8, 'Green Tea', 'Food & Beverage', 'CoffeeCo', 1, 18.50, 18.50, 0.50, 'PayPal'),
-- Order 3
(3, 'Order #ORD-003', '2024-03-03', 'Processing', 3, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', 'Mexico', 6, 'Running Shoes', 'Sports & Fitness', 'SportsBrand', 1, 129.99, 129.99, 0.00, 'Credit Card'),
(3, 'Order #ORD-003', '2024-03-03', 'Processing', 3, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', 'Mexico', 3, 'Yoga Mat', 'Sports & Fitness', 'FitGear', 1, 35.50, 35.50, 0.00, 'Credit Card'),
(3, 'Order #ORD-003', '2024-03-03', 'Processing', 3, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', 'Mexico', 2, 'Organic Coffee Beans', 'Food & Beverage', 'CoffeeCo', 1, 24.99, 24.99, 0.00, 'Credit Card'),
-- Order 4
(4, 'Order #ORD-004', '2024-03-04', 'Completed', 4, 'Sophie Martin', 'sophie.martin@email.com', 'France', 5, 'Ceramic Mug', 'Home & Garden', 'HomeWare', 2, 12.99, 25.98, 1.00, 'Bank Transfer'),
(4, 'Order #ORD-004', '2024-03-04', 'Completed', 4, 'Sophie Martin', 'sophie.martin@email.com', 'France', 8, 'Green Tea', 'Food & Beverage', 'CoffeeCo', 1, 18.50, 18.50, 0.50, 'Bank Transfer'),
-- Order 5
(5, 'Order #ORD-005', '2024-03-05', 'Shipped', 5, 'Yuki Tanaka', 'yuki.tanaka@email.com', 'Japan', 6, 'Running Shoes', 'Sports & Fitness', 'SportsBrand', 1, 129.99, 129.99, 5.00, 'Credit Card'),
(5, 'Order #ORD-005', '2024-03-05', 'Shipped', 5, 'Yuki Tanaka', 'yuki.tanaka@email.com', 'Japan', 1, 'Wireless Headphones', 'Electronics', 'TechCorp', 1, 89.99, 89.99, 4.50, 'Credit Card'),
(5, 'Order #ORD-005', '2024-03-05', 'Shipped', 5, 'Yuki Tanaka', 'yuki.tanaka@email.com', 'Japan', 4, 'Smartphone Case', 'Electronics', 'TechCorp', 1, 15.99, 15.99, 0.50, 'Credit Card'),
-- Order 6
(6, 'Order #ORD-006', '2024-03-06', 'Completed', 6, 'Maria Silva', 'maria.silva@email.com', 'Brazil', 10, 'Protein Powder', 'Sports & Fitness', 'NutritionPlus', 1, 79.99, 79.99, 3.00, 'PayPal'),
(6, 'Order #ORD-006', '2024-03-06', 'Completed', 6, 'Maria Silva', 'maria.silva@email.com', 'Brazil', 5, 'Ceramic Mug', 'Home & Garden', 'HomeWare', 1, 12.99, 12.99, 0.00, 'PayPal'),
-- Order 7
(7, 'Order #ORD-007', '2024-03-07', 'Processing', 1, 'John Smith', 'john.smith@email.com', 'USA', 9, 'Desk Lamp', 'Home & Garden', 'HomeWare', 1, 55.99, 55.99, 0.00, 'Credit Card'),
-- Order 8
(8, 'Order #ORD-008', '2024-03-08', 'Completed', 7, 'David Wilson', 'david.wilson@email.com', 'UK', 7, 'Laptop Stand', 'Electronics', 'OfficeSupply', 2, 45.00, 90.00, 2.50, 'Credit Card'),
(8, 'Order #ORD-008', '2024-03-08', 'Completed', 7, 'David Wilson', 'david.wilson@email.com', 'UK', 1, 'Wireless Headphones', 'Electronics', 'TechCorp', 1, 89.99, 89.99, 2.50, 'Credit Card'),
-- Order 10
(10, 'Order #ORD-010', '2024-03-10', 'Shipped', 9, 'Ahmed Hassan', 'ahmed.hassan@email.com', 'Egypt', 6, 'Running Shoes', 'Sports & Fitness', 'SportsBrand', 2, 129.99, 259.98, 10.00, 'Bank Transfer'),
(10, 'Order #ORD-010', '2024-03-10', 'Shipped', 9, 'Ahmed Hassan', 'ahmed.hassan@email.com', 'Egypt', 9, 'Desk Lamp', 'Home & Garden', 'HomeWare', 1, 55.99, 55.99, 5.00, 'Bank Transfer');