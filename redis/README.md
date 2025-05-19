# Docker Redis Setup

This project provides a Docker setup for running a Redis instance with automatic sample data initialization.

## Prerequisites

- Docker installed on your system.

## Setup

1. Navigate to the `redis` directory:
   ```bash
   cd redis
   ```

2. Run the docker-compose file to start the Redis container:
   ```bash
   docker-compose up -d
   ```

This will start a Redis container named `redis`. The Redis instance will be accessible on port `6379` on your local machine.

## Verifying the Data

You can use the provided test script to verify that the data was loaded correctly:

```bash
./test.sh
```

This will display sample data from each category to confirm successful initialization.

Note: Make sure to run this after the container has fully started and the initialization process has completed.

## Cleanup

To stop and remove the Redis container, run the following command in the `redis` directory:

```bash
docker-compose down
```

## Sample Data

The Redis container automatically initializes with sample data when it starts. This is handled by the custom cmd script (`init.sh`) which:

1. Starts the Redis server
2. Waits for Redis to be ready
3. Loads the sample data

The initialization process loads the following sample data:

- Users (john_doe, jane_smith, alice_jones)
- Categories (Electronics, Books, Clothing, Home Goods)
- Items (Laptop Pro, Wireless Mouse, etc.)
- Orders and Order Items

The data structure in Redis is modeled using Redis data types:
- Hashes for entity data (users, items, etc.)
- Sets for indexes and relationships
- String counters for auto-incrementing IDs

## Accessing the Data

You can connect to the Redis instance and query the data using the redis-cli:

```bash
docker exec -it redis redis-cli
```

Example commands:
```
# Get all user data for user 1
HGETALL user:1

# Get all items in the Electronics category
SMEMBERS items:by_category:1

# Get all orders for user 1
SMEMBERS orders:by_user:1

# Get details of an order
HGETALL order:1

# Get items in an order
SMEMBERS order_items:by_order:1
```

For more advanced configurations and options, refer to the official Redis Docker Hub page:
https://hub.docker.com/_/redis
