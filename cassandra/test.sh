#!/bin/bash

# Configuration
CONTAINER_NAME="cassandra"
KEYSPACE_NAME="mykeyspace"
MAX_RETRIES=30
RETRY_INTERVAL=10
# Define tables and expected counts
declare -A TABLE_COUNTS=(
    ["users"]=3
    ["categories"]=4
    ["items"]=6
    ["orders"]=3
    ["order_items"]=5
)

# Function to filter Cassandra output (removes headers, empty lines, etc.)
filter_cqlsh_output() {
    grep -v '^\s*$' | \
    grep -v '\-\-\-' | \
    grep -v 'cqlsh' | \
    grep -v 'Connected to' | \
    grep -v 'Cluster' | \
    grep -v '\[cqlsh' | \
    sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'
}

# Function to execute CQL and capture output
execute_cql() {
    local query="$1"
    docker exec -i "$CONTAINER_NAME" cqlsh --keyspace="$KEYSPACE_NAME" -e "$query" | \
    filter_cqlsh_output | tail -n 1
}

# Function to validate count
validate_count() {
    local description="$1"
    local table_name="$2"
    local expected_count="$3"
    local actual_count
    local query="SELECT * FROM $table_name LIMIT 1000;"
    
    # Retry mechanism for Cassandra eventual consistency
    for i in {1..10}; do
        # Execute query and count rows
        actual_count=$(docker exec -i "$CONTAINER_NAME" cqlsh --keyspace="$KEYSPACE_NAME" -e "$query" | \
                      filter_cqlsh_output | grep -v '(' | wc -l | tr -d ' ')
        
        # Subtract header row if count > 0
        [ "$actual_count" -gt 0 ] && actual_count=$((actual_count - 1))
        
        # Check if count matches expected
        if [ "$actual_count" -eq "$expected_count" ]; then
            echo "✓ $description (expected $expected_count, got $actual_count)"
            return 0
        fi
        
        if [ $i -lt 10 ]; then
            echo "  Retrying ($i/10)... (got '$actual_count')"
            sleep 5
        fi
    done
    
    echo "✗ $description (expected $expected_count, got '$actual_count' after multiple retries)"
    return 1
}

# Function to check if Cassandra is ready
check_cassandra_ready() {
    docker exec -i "$CONTAINER_NAME" cqlsh -e "DESCRIBE KEYSPACE $KEYSPACE_NAME;" > /dev/null 2>&1
    return $?
}

# Main script execution
echo "Running Cassandra validation checks..."
echo "Waiting for Cassandra container and initialization (this might take a moment)..."

# Wait for Cassandra to be ready with timeout
RETRY_COUNT=0
while ! check_cassandra_ready; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Timed out waiting for Cassandra to be ready after $((MAX_RETRIES * RETRY_INTERVAL)) seconds"
        exit 1
    fi
    echo "Waiting for Cassandra to be ready... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
done

echo "Cassandra is ready. Proceeding with validation checks..."

FAILURES=0

# Validate table data counts
for table in "${!TABLE_COUNTS[@]}"; do
    if ! validate_count "${table^} table has data" "$table" "${TABLE_COUNTS[$table]}"; then
        FAILURES=$((FAILURES+1))
    fi
done

# Check for tables in keyspace
TABLE_CHECK_QUERY="SELECT table_name FROM system_schema.tables WHERE keyspace_name = '$KEYSPACE_NAME';"
NUM_TABLES=$(docker exec -i "$CONTAINER_NAME" cqlsh -e "$TABLE_CHECK_QUERY" | \
             filter_cqlsh_output | grep -v 'table_name' | wc -l | tr -d ' ')

if [ "$NUM_TABLES" -ge "${#TABLE_COUNTS[@]}" ]; then
    echo "✓ Keyspace '$KEYSPACE_NAME' contains $NUM_TABLES tables."
else
    echo "✗ Keyspace '$KEYSPACE_NAME' check failed (expected at least ${#TABLE_COUNTS[@]} tables, found $NUM_TABLES)."
    FAILURES=$((FAILURES+1))
fi

# Final result
echo
if [ $FAILURES -eq 0 ]; then
    echo "All Cassandra validation checks passed. Initialization successful."
    exit 0
else
    echo "$FAILURES Cassandra validation checks failed. Initialization may be incomplete or there are issues."
    exit 1
fi
