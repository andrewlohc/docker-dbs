#!/bin/bash
set -e

ES_URL="http://elasticsearch:9200"

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch..."
until curl -s -o /dev/null -w '%{http_code}' "$ES_URL" | grep -q "200"; do
  sleep 5
done
echo "Elasticsearch is up"

# Create indices with mappings
echo "Creating indices..."
for index in users categories items orders; do
  curl -s -X DELETE "$ES_URL/$index" > /dev/null 2>&1 || true
done

# Define and create indices
curl -s -X PUT "$ES_URL/users" -H 'Content-Type: application/json' -d'{
  "mappings": {
    "properties": {
      "user_id": { "type": "integer" },
      "username": { "type": "keyword" },
      "email": { "type": "keyword" },
      "password_hash": { "type": "text", "index": false },
      "created_at": { "type": "date" }
    }
  }
}'

curl -s -X PUT "$ES_URL/categories" -H 'Content-Type: application/json' -d'{
  "mappings": {
    "properties": {
      "category_id": { "type": "integer" },
      "category_name": { "type": "keyword" }
    }
  }
}'

curl -s -X PUT "$ES_URL/items" -H 'Content-Type: application/json' -d'{
  "mappings": {
    "properties": {
      "item_id": { "type": "integer" },
      "item_name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "description": { "type": "text" },
      "price": { "type": "float" },
      "category_id": { "type": "integer" },
      "stock_quantity": { "type": "integer" },
      "created_at": { "type": "date" }
    }
  }
}'

curl -s -X PUT "$ES_URL/orders" -H 'Content-Type: application/json' -d'{
  "mappings": {
    "properties": {
      "order_id": { "type": "integer" },
      "user_id": { "type": "integer" },
      "order_date": { "type": "date" },
      "total_amount": { "type": "float" },
      "status": { "type": "keyword" },
      "order_items": {
        "type": "nested",
        "properties": {
          "item_id": { "type": "integer" },
          "quantity": { "type": "integer" },
          "price_at_purchase": { "type": "float" }
        }
      }
    }
  }
}'

# Current timestamp for consistent dates
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Bulk insert data
echo "Inserting data..."
curl -s -X POST "$ES_URL/_bulk" -H 'Content-Type: application/x-ndjson' --data-binary @- <<EOF
{ "index" : { "_index" : "users", "_id" : "1" } }
{ "user_id": 1, "username": "john_doe", "email": "john.doe@example.com", "password_hash": "hashed_password1", "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "users", "_id" : "2" } }
{ "user_id": 2, "username": "jane_smith", "email": "jane.smith@example.com", "password_hash": "hashed_password2", "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "users", "_id" : "3" } }
{ "user_id": 3, "username": "alice_jones", "email": "alice.jones@example.com", "password_hash": "hashed_password3", "created_at": "$TIMESTAMP" }

{ "index" : { "_index" : "categories", "_id" : "1" } }
{ "category_id": 1, "category_name": "Electronics" }
{ "index" : { "_index" : "categories", "_id" : "2" } }
{ "category_id": 2, "category_name": "Books" }
{ "index" : { "_index" : "categories", "_id" : "3" } }
{ "category_id": 3, "category_name": "Clothing" }
{ "index" : { "_index" : "categories", "_id" : "4" } }
{ "category_id": 4, "category_name": "Home Goods" }

{ "index" : { "_index" : "items", "_id" : "1" } }
{ "item_id": 1, "item_name": "Laptop Pro", "description": "High-performance laptop for professionals", "price": 1200.00, "category_id": 1, "stock_quantity": 50, "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "items", "_id" : "2" } }
{ "item_id": 2, "item_name": "Wireless Mouse", "description": "Ergonomic wireless mouse", "price": 25.00, "category_id": 1, "stock_quantity": 200, "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "items", "_id" : "3" } }
{ "item_id": 3, "item_name": "The Great Novel", "description": "A captivating story of adventure", "price": 15.99, "category_id": 2, "stock_quantity": 100, "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "items", "_id" : "4" } }
{ "item_id": 4, "item_name": "Learning SQL", "description": "Comprehensive guide to SQL", "price": 45.50, "category_id": 2, "stock_quantity": 75, "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "items", "_id" : "5" } }
{ "item_id": 5, "item_name": "T-Shirt", "description": "Comfortable cotton t-shirt", "price": 19.99, "category_id": 3, "stock_quantity": 150, "created_at": "$TIMESTAMP" }
{ "index" : { "_index" : "items", "_id" : "6" } }
{ "item_id": 6, "item_name": "Coffee Maker", "description": "Drip coffee maker with timer", "price": 59.95, "category_id": 4, "stock_quantity": 80, "created_at": "$TIMESTAMP" }

{ "index" : { "_index" : "orders", "_id" : "1" } }
{ "order_id": 1, "user_id": 1, "order_date": "$TIMESTAMP", "total_amount": 1225.00, "status": "completed", "order_items": [ { "item_id": 1, "quantity": 1, "price_at_purchase": 1200.00 }, { "item_id": 2, "quantity": 1, "price_at_purchase": 25.00 } ] }
{ "index" : { "_index" : "orders", "_id" : "2" } }
{ "order_id": 2, "user_id": 2, "order_date": "$TIMESTAMP", "total_amount": 61.49, "status": "shipped", "order_items": [ { "item_id": 3, "quantity": 1, "price_at_purchase": 15.99 }, { "item_id": 4, "quantity": 1, "price_at_purchase": 45.50 } ] }
{ "index" : { "_index" : "orders", "_id" : "3" } }
{ "order_id": 3, "user_id": 1, "order_date": "$TIMESTAMP", "total_amount": 19.99, "status": "pending", "order_items": [ { "item_id": 5, "quantity": 1, "price_at_purchase": 19.99 } ] }
EOF

echo "Initialization complete"
