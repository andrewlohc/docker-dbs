# Docker Cassandra Setup

This project provides a Docker setup for running an Apache Cassandra database with initialization using a CQL file.

## Prerequisites

- Docker installed on your system.
- Docker Compose installed on your system.

## Setup

1.  Navigate to the `cassandra` directory:
    ```bash
    cd cassandra
    ```

2.  Run the docker-compose file to start the Cassandra container:
    ```bash
    docker-compose up -d
    ```

This will start a Cassandra container named `cassandra` and a separate initialization container named `cassandra-init` that waits for Cassandra to be ready and then loads the `init.cql` file to create a keyspace, tables, and insert sample data. The database will be accessible on port `9042` (CQL native protocol) on your local machine.

## Verifying the Data

You can use the provided test script to verify that the data was loaded correctly:

```bash
./test.sh
```

This script performs several validation checks:
- Waits for the Cassandra container to be ready with a timeout mechanism
- Verifies that each table contains the expected number of records
- Confirms that all expected tables exist in the keyspace
- Provides detailed output with checkmarks (✓) for passing tests and X marks (✗) for failing tests

The script includes retry mechanisms to account for Cassandra's eventual consistency, ensuring reliable test results.

**Note:** Make sure to run this after the container has fully started and the initialization process has completed (this might take a minute or two for Cassandra).

## Cleanup

To stop and remove the Cassandra container and associated network, run the following command in the `cassandra` directory:

```bash
docker-compose down
```
If you created a volume for persistent data (e.g., `cassandra-data`), you might need to remove it manually if desired:
```bash
docker volume rm cassandra_cassandra-data # Adjust volume name if you changed it
```

## Loading CQL Files in Cassandra

Unlike PostgreSQL, Cassandra doesn't have a built-in mechanism to automatically execute SQL/CQL files during initialization. Instead, this project demonstrates how to load CQL files in Cassandra using the following approach:

1. **Create a CQL file** (`init.cql`) with your Cassandra Query Language commands
2. **Configure docker-compose.yml** to:
   - Set up a main Cassandra service with a healthcheck
   - Create a separate initialization service using the Cassandra image that:
     - Depends on the Cassandra service being healthy
     - Mounts the CQL file
     - Executes the CQL file using `cqlsh -f` once the main service is healthy
   - Define a custom network to ensure proper hostname resolution between services

This approach provides a similar experience to PostgreSQL's SQL file loading while working within Cassandra's capabilities.

## Connecting to Cassandra

### Using `cqlsh`

1.  **Connect to the container:**
    ```bash
    docker exec -it cassandra cqlsh
    ```

2.  **Once in the `cqlsh` prompt, you can interact with your keyspace (default: `mykeyspace`):**
    ```cql
    USE mykeyspace;
    SELECT * FROM users;
    ```

### Connecting with DBeaver

If you are using DBeaver Community Edition to connect to Cassandra:

*   You will need the Cassandra JDBC driver. You can find releases here: [Cassandra JDBC Driver Wrapper Releases](https://github.com/ing-bank/cassandra-jdbc-wrapper/releases)
*   Download the appropriate `cassandra-jdbc-wrapper-x.x.x-bundle.jar`.
*   In DBeaver, when setting up a new Cassandra connection, point to this JAR file.
*   The JDBC URL format is:
    ```jdbc
    jdbc:cassandra://localhost:9042/mykeyspace?localdatacenter=datacenter1
    ```
    (Ensure `mykeyspace` and `datacenter1` match your setup. `datacenter1` is the default in the `docker-compose.yml`.)

## Cassandra Initialization (`init.cql`)

The `init.cql` file sets up a sample e-commerce database schema within the `mykeyspace` keyspace. It creates and populates the following tables:

*   **`users`**: Stores user information.
    *   `user_id`: `uuid` (Primary Key)
    *   `username`: `text`
    *   `email`: `text`
    *   `password_hash`: `text`
    *   `created_at`: `timestamp`
    *   Indexes on `username` and `email`.

*   **`categories`**: Stores product categories.
    *   `category_id`: `uuid` (Primary Key)
    *   `category_name`: `text`
    *   Index on `category_name`.

*   **`items`**: Stores information about individual products.
    *   `item_id`: `uuid` (Primary Key)
    *   `item_name`: `text`
    *   `description`: `text`
    *   `price`: `decimal`
    *   `category_id`: `uuid` (Can be used for lookups if needed, but `category_name` is denormalized)
    *   `category_name`: `text` (Denormalized for easier querying)
    *   `stock_quantity`: `int`
    *   `created_at`: `timestamp`
    *   Index on `category_name`.

*   **`orders`**: Stores order information.
    *   `order_id`: `uuid` (Primary Key)
    *   `user_id`: `uuid` (Can be used for lookups if needed, but `username` is denormalized)
    *   `username`: `text` (Denormalized for easier querying)
    *   `order_date`: `timestamp`
    *   `total_amount`: `decimal`
    *   `status`: `text`
    *   Indexes on `user_id` and `status`.

*   **`order_items`**: Represents items within an order.
    *   `order_item_id`: `uuid` (Primary Key)
    *   `order_id`: `uuid`
    *   `item_id`: `uuid` (Can be used for lookups if needed, but `item_name` is denormalized)
    *   `item_name`: `text` (Denormalized)
    *   `quantity`: `int`
    *   `price_at_purchase`: `decimal`
    *   Indexes on `order_id` and `item_id`.

The initialization process waits for Cassandra to be ready, then executes CQL commands to define the schema and insert sample data. Note that Cassandra's data modeling often involves denormalization for query efficiency, which is reflected in some table designs (e.g., `category_name` in `items`, `username` in `orders`).

