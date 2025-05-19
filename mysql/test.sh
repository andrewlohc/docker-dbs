#!/bin/bash

# Adjusted for MySQL - using environment variables for credentials to avoid password warning
MYSQL_EXEC="docker exec -i -e MYSQL_PWD=mysql mysql mysql -u root mysql -e"
MYSQL_EXEC_QUIET="docker exec -i -e MYSQL_PWD=mysql mysql mysql -u root mysql -N -B -e"

# Function to run a validation query and check result
validate() {
    local description=$1
    local query=$2
    local expected=$3
    local actual=$($MYSQL_EXEC_QUIET "$query")
    
    if [ "$actual" -eq "$expected" ]; then
        echo "✓ $description"
        return 0
    else
        echo "✗ $description (expected $expected, got $actual)"
        return 1
    fi
}

echo "Running essential MySQL validation checks..."
echo

# Track validation failures
FAILURES=0

# Essential validation checks
# Adjusted query for MySQL information_schema
if ! validate "All tables exist" "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME IN ('users', 'categories', 'items', 'orders', 'order_items');" 5; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Users table has data" "SELECT COUNT(*) FROM users;" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Categories table has data" "SELECT COUNT(*) FROM categories;" 4; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Items table has data" "SELECT COUNT(*) FROM items;" 6; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Orders table has data" "SELECT COUNT(*) FROM orders;" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Order items table has data" "SELECT COUNT(*) FROM order_items;" 5; then
    FAILURES=$((FAILURES+1))
fi

# Check critical relationships
if ! validate "Foreign key integrity" "
    SELECT CASE WHEN (
        (SELECT COUNT(*) FROM order_items oi LEFT JOIN items i ON oi.item_id = i.item_id WHERE i.item_id IS NULL) +
        (SELECT COUNT(*) FROM orders o LEFT JOIN users u ON o.user_id = u.user_id WHERE u.user_id IS NULL) +
        (SELECT COUNT(*) FROM items i LEFT JOIN categories c ON i.category_id = c.category_id WHERE i.category_id IS NOT NULL AND c.category_id IS NULL)
    ) = 0 THEN 1 ELSE 0 END;" 1; then
    FAILURES=$((FAILURES+1))
fi

# Final result
echo
if [ $FAILURES -eq 0 ]; then
    echo "All validation checks passed. MySQL initialization successful."
    exit 0
else
    echo "$FAILURES validation checks failed. MySQL initialization may be incomplete."
    exit 1
fi
