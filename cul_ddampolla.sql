/* ==================
   DATABASE CREATION
   ================== */
CREATE DATABASE cul_dampolla_db;

USE cul_dampolla_db;

/* ==================
   TABLE CREATION
   ================== */
CREATE TABLE suppliers(
	supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    street VARCHAR(100),
    number INT,
    floor VARCHAR(10),
    door VARCHAR(10),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    phone VARCHAR(20), 
    fax VARCHAR(20),
    nif VARCHAR(20)
);

CREATE TABLE brands(
	brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    supplier_id INT,
    
    CONSTRAINT fk_brands_suppliers
    FOREIGN KEY (supplier_id)
		REFERENCES suppliers(supplier_id)
);

CREATE TABLE glasses(
	glasses_id INT PRIMARY KEY AUTO_INCREMENT,
    brand_id INT,
    prescription DECIMAL(4, 2),
	glass_color VARCHAR(50),
    frame_type ENUM('floating', 'horn-rimmed', 'metal'),
    frame_color VARCHAR(50),
    price DECIMAL(6,2),
    
    CONSTRAINT fk_glasses_brands
    FOREIGN KEY (brand_id)
		REFERENCES brands(brand_id)
);

CREATE TABLE clients(
	client_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    registration_date DATE DEFAULT (CURRENT_DATE),
    referrer_client_id INT,
    
    CONSTRAINT fk_clients_clients
    FOREIGN KEY (referrer_client_id)
		REFERENCES clients(client_id)
);

CREATE TABLE employees(
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE sales(
	sale_id INT PRIMARY KEY AUTO_INCREMENT,
    glasses_id INT NOT NULL,
    employee_id INT NOT NULL,
	client_id INT NOT NULL,
	sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_sales_glasses
	FOREIGN KEY (glasses_id)
		REFERENCES glasses(glasses_id),
    CONSTRAINT fk_sales_employees
    FOREIGN KEY (employee_id)
		REFERENCES employees(employee_id),
    CONSTRAINT fk_sales_clients
	FOREIGN KEY (client_id)
		REFERENCES clients(client_id)
);

/* ==================
   TEST DATA
   ================== */
INSERT INTO suppliers (name, street, number, city, postal_code, country, phone, fax, nif)
VALUES 
('OptiVision SL', 'Gran Via', 120, 'Barcelona', '08010', 'Spain', '600111222', '933333333', 'B12345678'),
('LensWorld', 'Diagonal', 300, 'Barcelona', '08018', 'Spain', '600222333', '933444555', 'B87654321'),
('VisionTech', 'Passeig de Gràcia', 145, 'Barcelona', '08008', 'Spain', '600555777', '934567890', 'B11223344');

INSERT INTO brands (name, supplier_id)
VALUES
('RayBan', 1),
('Oakley', 1),
('Prada', 2);

INSERT INTO glasses (brand_id, prescription, glass_color, frame_type, frame_color, price)
VALUES
(1, -2.50, 'transparent', 'floating', 'black', 120.00),
(2, 1.75, 'blue', 'metal', 'silver', 200.00),
(3, 0.00, 'green', 'horn-rimmed', 'brown', 350.00);

INSERT INTO clients (name, address, phone, email)
VALUES
('Anna Garcia', 'Carrer Balmes 10, Barcelona', '600123123', 'anna@email.com'),
('Joan Puig', 'Carrer Mallorca 50, Barcelona', '600456456', 'joan@email.com');

INSERT INTO employees (name)
VALUES
('Maria Lopez'),
('Carlos Perez');

INSERT INTO sales (glasses_id, employee_id, client_id)
VALUES
(1, 1, 1),
(2, 2, 2),
(1, 2, 2),
(3, 1, 2);

/* ==================
   QUERIES
   ================== */
-- Total purchases of a client
SELECT
	c.name,
    COUNT(s.sale_id) AS total_purchases
FROM sales s
JOIN clients c ON s.client_id = c.client_id
WHERE c.client_id=2
GROUP BY c.name;

-- Glasses sold by an employee during a year
SELECT
	e.name AS seller,
    s.glasses_id,
    s.sale_date
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
WHERE e.employee_id=1 AND s.sale_date >= '2026-01-01' AND s.sale_date < '2027-01-01';

-- List of the suppliers with sucessfull sales
SELECT DISTINCT
	su.name AS supplier
FROM sales s
JOIN glasses g ON s.glasses_id = g.glasses_id
JOIN brands b ON g.brand_id = b.brand_id
JOIN suppliers su ON b.supplier_id = su.supplier_id