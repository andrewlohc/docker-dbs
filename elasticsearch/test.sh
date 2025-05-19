#!/bin/bash

ES_URL="http://localhost:9200"

# Track validation failures
FAILURES=0

# Function to validate with simple output
validate() {
    local description=$1
    local command=$2
    local expected=$3
    local actual=$(eval "$command")
    
    if [ "$actual" -eq "$expected" ]; then
        echo "✓ $description"
        return 0
    else
        echo "✗ $description (expected $expected, got $actual)"
        FAILURES=$((FAILURES+1))
        return 1
    fi
}

# Run validations
echo "Running validation checks..."

# Check indices exist and have correct document counts
validate "Users index" "curl -s -X GET '$ES_URL/users/_count' | grep -o '\"count\":[0-9]*' | sed 's/\"count\"://'" 3
validate "Categories index" "curl -s -X GET '$ES_URL/categories/_count' | grep -o '\"count\":[0-9]*' | sed 's/\"count\"://'" 4
validate "Items index" "curl -s -X GET '$ES_URL/items/_count' | grep -o '\"count\":[0-9]*' | sed 's/\"count\"://'" 6
validate "Orders index" "curl -s -X GET '$ES_URL/orders/_count' | grep -o '\"count\":[0-9]*' | sed 's/\"count\"://'" 3

# Check nested items in orders
validate "Order 1 items" "curl -s -X GET '$ES_URL/orders/_doc/1' | grep -o '\"item_id\"' | wc -l | tr -d ' '" 2
validate "Order 2 items" "curl -s -X GET '$ES_URL/orders/_doc/2' | grep -o '\"item_id\"' | wc -l | tr -d ' '" 2
validate "Order 3 items" "curl -s -X GET '$ES_URL/orders/_doc/3' | grep -o '\"item_id\"' | wc -l | tr -d ' '" 1

# Final result
if [ $FAILURES -eq 0 ]; then
    echo "All validation checks passed."
    exit 0
else
    echo "$FAILURES validation checks failed."
    exit 1
fi
