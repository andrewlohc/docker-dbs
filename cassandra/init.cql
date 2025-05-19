-- Create Keyspace
CREATE KEYSPACE IF NOT EXISTS mykeyspace
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

USE mykeyspace;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id uuid PRIMARY KEY,
    username text,
    email text,
    password_hash text,
    created_at timestamp
);
CREATE INDEX IF NOT EXISTS ON users (username);
CREATE INDEX IF NOT EXISTS ON users (email);

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
    category_id uuid PRIMARY KEY,
    category_name text
);
CREATE INDEX IF NOT EXISTS ON categories (category_name);

-- Items Table
CREATE TABLE IF NOT EXISTS items (
    item_id uuid PRIMARY KEY,
    item_name text,
    description text,
    price decimal,
    category_id uuid, -- Denormalized, or could be category_name
    category_name text, -- Denormalized for easier querying
    stock_quantity int,
    created_at timestamp
);
CREATE INDEX IF NOT EXISTS ON items (category_name); -- Index on denormalized field

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id uuid PRIMARY KEY,
    user_id uuid,
    username text, -- Denormalized for easier querying
    order_date timestamp,
    total_amount decimal,
    status text
);
CREATE INDEX IF NOT EXISTS ON orders (user_id);
CREATE INDEX IF NOT EXISTS ON orders (status);

-- Order Items Table
-- In Cassandra, this is often denormalized into the orders table or handled differently.
-- For a similar structure, we can create it, but querying across orders and items requires client-side logic or Spark.
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id uuid PRIMARY KEY,
    order_id uuid,
    item_id uuid,
    item_name text, -- Denormalized
    quantity int,
    price_at_purchase decimal
);
CREATE INDEX IF NOT EXISTS ON order_items (order_id);
CREATE INDEX IF NOT EXISTS ON order_items (item_id);

-- Sample Data (using fixed UUIDs for simplicity in a test script)

-- Users
INSERT INTO users (user_id, username, email, password_hash, created_at) VALUES
(uuid(), 'john_doe', 'john.doe@example.com', 'hashed_password1', toTimestamp(now()));
INSERT INTO users (user_id, username, email, password_hash, created_at) VALUES
(uuid(), 'jane_smith', 'jane.smith@example.com', 'hashed_password2', toTimestamp(now()));
INSERT INTO users (user_id, username, email, password_hash, created_at) VALUES
(uuid(), 'alice_jones', 'alice.jones@example.com', 'hashed_password3', toTimestamp(now()));

-- Categories
INSERT INTO categories (category_id, category_name) VALUES (uuid(), 'Electronics');
INSERT INTO categories (category_id, category_name) VALUES (uuid(), 'Books');
INSERT INTO categories (category_id, category_name) VALUES (uuid(), 'Clothing');
INSERT INTO categories (category_id, category_name) VALUES (uuid(), 'Home Goods');

-- Items (Assuming category_ids are known or fetched. For simplicity, using names directly)
-- For a real app, you'd fetch category_id based on category_name.
-- Here, we'll insert category_name directly into items for denormalization.
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'Laptop Pro', 'High-performance laptop for professionals', 1200.00, 'Electronics', 50, toTimestamp(now()));
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'Wireless Mouse', 'Ergonomic wireless mouse', 25.00, 'Electronics', 200, toTimestamp(now()));
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'The Great Novel', 'A captivating story of adventure', 15.99, 'Books', 100, toTimestamp(now()));
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'Learning SQL', 'Comprehensive guide to SQL', 45.50, 'Books', 75, toTimestamp(now()));
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'T-Shirt', 'Comfortable cotton t-shirt', 19.99, 'Clothing', 150, toTimestamp(now()));
INSERT INTO items (item_id, item_name, description, price, category_name, stock_quantity, created_at) VALUES
(uuid(), 'Coffee Maker', 'Drip coffee maker with timer', 59.95, 'Home Goods', 80, toTimestamp(now()));

-- Orders (Assuming user_ids are known or fetched. For simplicity, using usernames directly)
-- For a real app, you'd fetch user_id based on username.
-- Here, we'll insert username directly into orders for denormalization.
INSERT INTO orders (order_id, username, order_date, total_amount, status) VALUES
(uuid(), 'john_doe', toTimestamp(now()), 1225.00, 'completed');
INSERT INTO orders (order_id, username, order_date, total_amount, status) VALUES
(uuid(), 'jane_smith', toTimestamp(now()), 61.49, 'shipped');
INSERT INTO orders (order_id, username, order_date, total_amount, status) VALUES
(uuid(), 'john_doe', toTimestamp(now()), 19.99, 'pending');

-- Order Items
-- In Cassandra, we can't use subqueries in INSERT statements
-- For a real application, you would need to:
-- 1. First query the orders table to get the order_ids
-- 2. Then use those order_ids in separate INSERT statements
-- For this example, we'll use hardcoded UUIDs for simplicity

-- Create some UUIDs for our order_items
-- In a real application, these would be retrieved from queries
-- or generated by the application logic
-- john_doe's first order (total_amount=1225.00)
INSERT INTO order_items (order_item_id, order_id, item_name, quantity, price_at_purchase) VALUES
(uuid(), uuid(), 'Laptop Pro', 1, 1200.00);
INSERT INTO order_items (order_item_id, order_id, item_name, quantity, price_at_purchase) VALUES
(uuid(), uuid(), 'Wireless Mouse', 1, 25.00);

-- jane_smith's order (total_amount=61.49)
INSERT INTO order_items (order_item_id, order_id, item_name, quantity, price_at_purchase) VALUES
(uuid(), uuid(), 'The Great Novel', 1, 15.99);
INSERT INTO order_items (order_item_id, order_id, item_name, quantity, price_at_purchase) VALUES
(uuid(), uuid(), 'Learning SQL', 1, 45.50);

-- john_doe's second order (total_amount=19.99)
INSERT INTO order_items (order_item_id, order_id, item_name, quantity, price_at_purchase) VALUES
(uuid(), uuid(), 'T-Shirt', 1, 19.99);
