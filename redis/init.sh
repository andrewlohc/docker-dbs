#!/bin/sh
set -e

# Start Redis server in the background
redis-server --appendonly yes &

# Wait for Redis to be ready
until redis-cli ping; do
  echo "Waiting for Redis to start..."
  sleep 1
done

echo "Redis is up, running initialization..."

# Function to execute Redis command
redis_cmd() {
  redis-cli "$@"
}

# Clear all existing data
redis_cmd FLUSHALL

# ----- USERS -----
redis_cmd HMSET user:1 username "john_doe" email "john.doe@example.com" password_hash "hashed_password1" created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET user:2 username "jane_smith" email "jane.smith@example.com" password_hash "hashed_password2" created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET user:3 username "alice_jones" email "alice.jones@example.com" password_hash "hashed_password3" created_at "2025-05-17T12:00:00Z"

# Create indexes for users (using sets)
redis_cmd SADD users:by_username:john_doe 1
redis_cmd SADD users:by_username:jane_smith 2
redis_cmd SADD users:by_username:alice_jones 3
redis_cmd SADD users:by_email:john.doe@example.com 1
redis_cmd SADD users:by_email:jane.smith@example.com 2
redis_cmd SADD users:by_email:alice.jones@example.com 3
redis_cmd SADD users:all 1 2 3

# ----- CATEGORIES -----
redis_cmd HMSET category:1 name "Electronics"
redis_cmd HMSET category:2 name "Books"
redis_cmd HMSET category:3 name "Clothing"
redis_cmd HMSET category:4 name "Home Goods"

# Create indexes for categories
redis_cmd SADD categories:by_name:Electronics 1
redis_cmd SADD categories:by_name:Books 2
redis_cmd SADD categories:by_name:Clothing 3
redis_cmd SADD categories:by_name:Home_Goods 4
redis_cmd SADD categories:all 1 2 3 4

# ----- ITEMS -----
redis_cmd HMSET item:1 name "Laptop Pro" description "High-performance laptop for professionals" price 1200.00 category_id 1 stock_quantity 50 created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET item:2 name "Wireless Mouse" description "Ergonomic wireless mouse" price 25.00 category_id 1 stock_quantity 200 created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET item:3 name "The Great Novel" description "A captivating story of adventure" price 15.99 category_id 2 stock_quantity 100 created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET item:4 name "Learning SQL" description "Comprehensive guide to SQL" price 45.50 category_id 2 stock_quantity 75 created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET item:5 name "T-Shirt" description "Comfortable cotton t-shirt" price 19.99 category_id 3 stock_quantity 150 created_at "2025-05-17T12:00:00Z"
redis_cmd HMSET item:6 name "Coffee Maker" description "Drip coffee maker with timer" price 59.95 category_id 4 stock_quantity 80 created_at "2025-05-17T12:00:00Z"

# Create indexes for items
redis_cmd SADD items:all 1 2 3 4 5 6
redis_cmd SADD items:by_category:1 1 2
redis_cmd SADD items:by_category:2 3 4
redis_cmd SADD items:by_category:3 5
redis_cmd SADD items:by_category:4 6

# ----- ORDERS -----
redis_cmd HMSET order:1 user_id 1 order_date "2025-05-17T12:00:00Z" total_amount 1225.00 status "completed"
redis_cmd HMSET order:2 user_id 2 order_date "2025-05-17T12:00:00Z" total_amount 61.49 status "shipped"
redis_cmd HMSET order:3 user_id 1 order_date "2025-05-17T12:00:00Z" total_amount 19.99 status "pending"

# Create indexes for orders
redis_cmd SADD orders:all 1 2 3
redis_cmd SADD orders:by_user:1 1 3
redis_cmd SADD orders:by_user:2 2
redis_cmd SADD orders:by_status:completed 1
redis_cmd SADD orders:by_status:shipped 2
redis_cmd SADD orders:by_status:pending 3

# ----- ORDER ITEMS -----
redis_cmd HMSET order_item:1 order_id 1 item_id 1 quantity 1 price_at_purchase 1200.00
redis_cmd HMSET order_item:2 order_id 1 item_id 2 quantity 1 price_at_purchase 25.00
redis_cmd HMSET order_item:3 order_id 2 item_id 3 quantity 1 price_at_purchase 15.99
redis_cmd HMSET order_item:4 order_id 2 item_id 4 quantity 1 price_at_purchase 45.50
redis_cmd HMSET order_item:5 order_id 3 item_id 5 quantity 1 price_at_purchase 19.99

# Create indexes for order items
redis_cmd SADD order_items:all 1 2 3 4 5
redis_cmd SADD order_items:by_order:1 1 2
redis_cmd SADD order_items:by_order:2 3 4
redis_cmd SADD order_items:by_order:3 5
redis_cmd SADD order_items:by_item:1 1
redis_cmd SADD order_items:by_item:2 2
redis_cmd SADD order_items:by_item:3 3
redis_cmd SADD order_items:by_item:4 4
redis_cmd SADD order_items:by_item:5 5

# Set counters for auto-incrementing IDs
redis_cmd SET counter:user_id 3
redis_cmd SET counter:category_id 4
redis_cmd SET counter:item_id 6
redis_cmd SET counter:order_id 3
redis_cmd SET counter:order_item_id 5

echo "Data loading completed successfully."

# Keep the container running
wait
