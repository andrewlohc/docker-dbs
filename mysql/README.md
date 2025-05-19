# Docker MySQL Setup

This project provides a simple Docker setup for running a MySQL database with an initialization script that creates an e-commerce database schema with sample data.

## Prerequisites

- Docker installed on your system.

## Setup

1. Run the docker-compose file to start the MySQL container:
   ```bash
   docker-compose up -d
   ```

This will start a MySQL container named `mysql` and execute the `init.sql` script to initialize the database. The database will be accessible on port `3306` on your local machine.

## Database Schema

The initialization script creates the following tables:

- `users`: Store user information (username, email, password hash)
- `categories`: Product categories
- `items`: Product inventory with details like price, description, and stock quantity
- `orders`: Customer orders with status tracking
- `order_items`: Junction table linking orders and items, including quantity and price at purchase

The script also populates these tables with sample data and creates appropriate indexes for performance optimization.

### Entity Relationship Overview

The database follows a standard e-commerce schema with the following relationships:
- Users can place multiple orders
- Items belong to categories
- Orders contain multiple items through the order_items junction table

## Verifying the Data

You can use the provided test script to verify that the data was loaded correctly:

```bash
# Make the script executable if needed
chmod +x test.sh

# Run the test script
./test.sh
```

This will run a series of validation checks to confirm that:
- All tables exist
- Each table contains the expected number of records
- Foreign key relationships are intact

Note: Make sure to run this after the container has fully started and the initialization process has completed.

## Cleanup

To stop and remove the MySQL container, run the following command:

```bash
docker-compose down
```

## Connection Details

You can connect to the MySQL database using the following credentials:

- **Host**: localhost
- **Port**: 3306
- **Username**: root
- **Password**: mysql
- **Database**: mysql

## Sample Data

The initialization script includes sample data:

- 3 users
- 4 product categories
- 6 items across different categories
- 3 orders with various statuses
- 5 order items connecting orders to products

This sample data allows you to immediately test queries and application functionality without having to create your own test data.

## Using with Applications

To connect an application to this database:

1. Configure your application's database connection settings using the credentials above.
2. Make sure your application is running on the same machine as the Docker container, or configure network settings appropriately if running in a distributed environment.
3. If you need to modify the database schema or initial data, edit the `init.sql` file before starting the container.

## Troubleshooting

If you encounter issues:

1. Check that the container is running with `docker ps`
2. View container logs with `docker logs mysql`
3. Ensure port 3306 is not already in use on your host machine
4. If you modified the init.sql file after first run, you may need to remove the container and volumes with `docker-compose down -v` before starting again
