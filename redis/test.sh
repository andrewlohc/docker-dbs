#!/bin/bash

REDIS_CLI="docker exec -i redis redis-cli"
REDIS_CLI_QUIET="docker exec -i redis redis-cli --raw"

# Function to run a validation query and check result
validate() {
    local description=$1
    local command=$2
    local expected=$3
    local actual=$($REDIS_CLI_QUIET $command)
    
    if [ "$actual" -eq "$expected" ]; then
        echo "✓ $description"
        return 0
    else
        echo "✗ $description (expected $expected, got $actual)"
        return 1
    fi
}

echo "Running essential Redis validation checks..."
echo

# Track validation failures
FAILURES=0

# Essential validation checks
if ! validate "All users exist" "SCARD users:all" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "All categories exist" "SCARD categories:all" 4; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "All items exist" "SCARD items:all" 6; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "All orders exist" "SCARD orders:all" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "All order items exist" "SCARD order_items:all" 5; then
    FAILURES=$((FAILURES+1))
fi

# Check relationships
if ! validate "Items by category 1" "SCARD items:by_category:1" 2; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Items by category 2" "SCARD items:by_category:2" 2; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Orders by user 1" "SCARD orders:by_user:1" 2; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Order items by order 1" "SCARD order_items:by_order:1" 2; then
    FAILURES=$((FAILURES+1))
fi

# Check counters
if ! validate "User ID counter" "GET counter:user_id" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Category ID counter" "GET counter:category_id" 4; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Item ID counter" "GET counter:item_id" 6; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Order ID counter" "GET counter:order_id" 3; then
    FAILURES=$((FAILURES+1))
fi

if ! validate "Order item ID counter" "GET counter:order_item_id" 5; then
    FAILURES=$((FAILURES+1))
fi

# Final result
echo
if [ $FAILURES -eq 0 ]; then
    echo "All validation checks passed. Redis initialization successful."
    exit 0
else
    echo "$FAILURES validation checks failed. Redis initialization may be incomplete."
    exit 1
fi
