-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- Items Table
CREATE TABLE items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category
        FOREIGN KEY(category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL
);

-- Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' NOT NULL,
    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Order Items Table (Junction table for Orders and Items)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_item
        FOREIGN KEY(item_id)
        REFERENCES items(item_id)
        ON DELETE RESTRICT
);

-- Optional: Add indexes for frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_items_category_id ON items(category_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_item_id ON order_items(item_id);

-- Sample Data

-- Users
INSERT INTO users (username, email, password_hash) VALUES
('john_doe', 'john.doe@example.com', 'hashed_password1'),
('jane_smith', 'jane.smith@example.com', 'hashed_password2'),
('alice_jones', 'alice.jones@example.com', 'hashed_password3');

-- Categories
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Books'),
('Clothing'),
('Home Goods');

-- Items
INSERT INTO items (item_name, description, price, category_id, stock_quantity) VALUES
('Laptop Pro', 'High-performance laptop for professionals', 1200.00, 1, 50),
('Wireless Mouse', 'Ergonomic wireless mouse', 25.00, 1, 200),
('The Great Novel', 'A captivating story of adventure', 15.99, 2, 100),
('Learning SQL', 'Comprehensive guide to SQL', 45.50, 2, 75),
('T-Shirt', 'Comfortable cotton t-shirt', 19.99, 3, 150),
('Coffee Maker', 'Drip coffee maker with timer', 59.95, 4, 80);

-- Orders
-- Order 1 for John Doe
INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 1225.00, 'completed');

-- Order 2 for Jane Smith
INSERT INTO orders (user_id, total_amount, status) VALUES
(2, 61.49, 'shipped');

-- Order 3 for John Doe (another order)
INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 19.99, 'pending');

-- Order Items
-- Order 1 items (Laptop Pro and Wireless Mouse)
INSERT INTO order_items (order_id, item_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 25.00);

-- Order 2 items (The Great Novel and Learning SQL)
INSERT INTO order_items (order_id, item_id, quantity, price_at_purchase) VALUES
(2, 3, 1, 15.99),
(2, 4, 1, 45.50);

-- Order 3 items (T-Shirt)
INSERT INTO order_items (order_id, item_id, quantity, price_at_purchase) VALUES
(3, 5, 1, 19.99);
