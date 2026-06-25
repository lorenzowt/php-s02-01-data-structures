/* ==================
   DATABASE CREATION
   ================== */
CREATE DATABASE pizza_shop_db;

USE pizza_shop_db;

/* ==================
   TABLE CREATION
   ================== */
CREATE TABLE clients(
	client_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    address VARCHAR(255),
    zipcode VARCHAR(20),
    city VARCHAR(100),
    province VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE shops(
	shop_id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(255),
    zipcode VARCHAR(20),
    city VARCHAR(100),
    province VARCHAR(100)
);

CREATE TABLE employees(
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    role ENUM('cook', 'delivery'),
    name VARCHAR(100),
    last_name VARCHAR(100),
    nif VARCHAR(20),
    phone VARCHAR(20),
    shop_id INT NOT NULL,
    
    CONSTRAINT fk_employees_shops
	FOREIGN KEY (shop_id)
		REFERENCES shops(shop_id)
);

CREATE TABLE pizza_categories(
	category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE products(
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    type ENUM ('pizza', 'drink', 'burger') NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    price DECIMAL(5, 2) NOT NULL,
    category_id INT,
    
    CONSTRAINT fk_pizzas_pizza_categories
	FOREIGN KEY (category_id)
		REFERENCES pizza_categories(category_id)
);


CREATE TABLE orders(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    shop_id INT NOT NULL,
    order_type ENUM ('delivery', 'pickup') NOT NULL,
    order_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_price DECIMAL (8, 2),
    
    delivery_employee_id INT NULL,
    delivery_datetime DATETIME NULL,
    
    CONSTRAINT fk_orders_clients
    FOREIGN KEY (client_id)
		REFERENCES clients(client_id),
	CONSTRAINT fk_orders_shops
    FOREIGN KEY (shop_id)
		REFERENCES shops(shop_id),
	CONSTRAINT fk_orders_employees
	FOREIGN KEY (delivery_employee_id)
		REFERENCES employees(employee_id)
);

CREATE TABLE order_products(
	id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    
    CONSTRAINT fk_order_products_orders
    FOREIGN KEY (order_id)
		REFERENCES orders(order_id),
	CONSTRAINT fk_order_products_products
	FOREIGN KEY (product_id)
		REFERENCES products(product_id)
);

/* ==================
   TEST DATA
   ================== */
INSERT INTO shops (address, zipcode, city, province) VALUES
('Carrer de Balmes 12', '08007', 'Barcelona', 'Barcelona'),
('Rambla Nova 88', '43001', 'Tarragona', 'Tarragona'),
('Carrer de Sants 55', '08014', 'Barcelona', 'Barcelona');

INSERT INTO clients (name, last_name, address, zipcode, city, province, phone) VALUES
('Marc', 'García', 'Carrer Aragó 101', '08015', 'Barcelona', 'Barcelona', '600111222'),
('Laura', 'Martínez', 'Carrer Provença 45', '08008', 'Barcelona', 'Barcelona', '600222333'),
('Jordi', 'Soler', 'Carrer Valencia 88', '08009', 'Barcelona', 'Barcelona', '600333444'),
('Anna', 'Ribas', 'Carrer Marina 120', '08013', 'Barcelona', 'Barcelona', '600444555'),
('Pau', 'Torres', 'Carrer Roselló 300', '08037', 'Barcelona', 'Barcelona', '600555666');

INSERT INTO employees (role, name, last_name, nif, phone, shop_id) VALUES
('cook', 'Carlos', 'Ruiz', '11111111A', '611111111', 1),
('cook', 'Marta', 'López', '22222222B', '622222222', 2),
('cook', 'Sergi', 'Vidal', '33333333C', '633333333', 3),
('delivery', 'David', 'Fernández', '44444444D', '644444444', 1),
('delivery', 'Elena', 'Sánchez', '55555555E', '655555555', 2);

INSERT INTO pizza_categories (name) VALUES
('Classic'),
('Gourmet'),
('Spicy');

INSERT INTO products (type, name, description, image_url, price, category_id) VALUES
('pizza', 'Margherita', 'Tomato, mozzarella, basil', 'img/margherita.jpg', 8.50, 1),
('pizza', 'Pepperoni', 'Tomato, mozzarella, pepperoni', 'img/pepperoni.jpg', 9.50, 3),
('burger', 'Classic Burger', 'Beef, lettuce, tomato, cheese', 'img/burger.jpg', 7.90, null),
('drink', 'Coca Cola', '330ml can', 'img/coke.jpg', 2.00, null),
('drink', 'Water', '500ml bottle', 'img/water.jpg', 1.50, null),
('burger', 'Chicken Burger', 'Chicken, mayo, lettuce', 'img/chicken.jpg', 8.20, null);


INSERT INTO orders (client_id, shop_id, order_type, total_price, delivery_employee_id, delivery_datetime) VALUES
(1, 1, 'delivery', 18.00, 4, '2026-06-03 12:30:00'),
(2, 2, 'pickup', 9.50, NULL, NULL),
(3, 1, 'delivery', 22.00, 5, '2026-06-03 13:10:00'),
(4, 3, 'pickup', 7.90, NULL, NULL),
(5, 2, 'delivery', 12.00, 4, '2026-06-03 14:00:00');

INSERT INTO order_products (order_id, product_id, quantity) VALUES
-- Order 1
(1, 1, 1), -- Margherita
(1, 4, 2), -- Coke

-- Order 2
(2, 2, 1), -- Pepperoni

-- Order 3
(3, 3, 2), -- Burger
(3, 5, 1), -- Water

-- Order 4
(4, 6, 1), -- Chicken Burger

-- Order 5
(5, 1, 1), -- Margherita
(5, 4, 1); -- Coke

/* ==================
   QUERIES
   ================== */

-- Count of drinks sold in Barcelona
SELECT
	s.city,
    SUM(op.quantity) AS drink_count
FROM orders o 
JOIN shops s ON o.shop_id = s.shop_id
JOIN order_products op ON o.order_id = op.order_id
JOIN products p ON op.product_id = p.product_id
WHERE s.city = 'Barcelona' AND p.type = 'drink'
GROUP BY s.city;

-- Count of drinks sold in each city
SELECT
	s.city,
    SUM(op.quantity) AS drink_count
FROM orders o 
JOIN shops s ON o.shop_id = s.shop_id
JOIN order_products op ON o.order_id = op.order_id
JOIN products p ON op.product_id = p.product_id
WHERE p.type = 'drink'
GROUP BY s.city;

-- Count of orders delivered by employee_id = 4
SELECT
	e.name,
    COUNT(o.order_id) as delivery_count
FROM orders o 
JOIN employees e ON o.delivery_employee_id = e.employee_id
WHERE e.employee_id = 4
GROUP BY e.employee_id, e.name;

-- Count of orders delivered by each employee
SELECT
	e.name,
    COUNT(o.order_id) as delivery_count
FROM orders o 
JOIN employees e ON o.delivery_employee_id = e.employee_id
GROUP BY e.employee_id, e.name;



















