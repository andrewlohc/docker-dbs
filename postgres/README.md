# Docker PostgreSQL Setup

This project provides a simple Docker setup for running a PostgreSQL database with an initialization script.

## Prerequisites

- Docker installed on your system.

## Setup

1. Navigate to the `postgres` directory:
   ```bash
   cd postgres
   ```

2. Run the docker-compose file to start the PostgreSQL container:
   ```bash
   docker-compose up -d
   ```

This will start a PostgreSQL container named `postgres` and execute the `init.sql` script to initialize the database. The database will be accessible on port `5432` on your local machine.

## Verifying the Data

You can use the provided test script to verify that the data was loaded correctly:

```bash
# Make the script executable if needed
chmod +x test.sh

# Run the test script
./test.sh
```

This will display sample data from each category to confirm successful initialization.

Note: Make sure to run this after the container has fully started and the initialization process has completed.

## Cleanup

To stop and remove the PostgreSQL container, run the following command in the `postgres` directory:

```bash
docker-compose down
```

## Connection Details

You can connect to the PostgreSQL database using the following credentials:

- **Host**: localhost
- **Port**: 5432
- **Username**: postgres
- **Password**: postgres
- **Database**: postgres

## PostgreSQL Initialization (`postgres/init.sql`)

The `postgres/init.sql` script sets up a sample e-commerce database schema. It creates and populates the following tables:

*   **`users`**: Stores user information, including username, email, and hashed password.
    *   `user_id`: Primary Key, auto-incrementing.
    *   `username`: Unique username.
    *   `email`: Unique email address.
    *   `password_hash`: Hashed password for security.
    *   `created_at`: Timestamp of when the user was created.

*   **`categories`**: Stores product categories.
    *   `category_id`: Primary Key, auto-incrementing.
    *   `category_name`: Unique name of the category (e.g., Electronics, Books).

*   **`items`**: Stores information about individual products.
    *   `item_id`: Primary Key, auto-incrementing.
    *   `item_name`: Name of the item.
    *   `description`: Detailed description of the item.
    *   `price`: Price of the item.
    *   `category_id`: Foreign Key referencing `categories.category_id`.
    *   `stock_quantity`: Current stock level of the item.
    *   `created_at`: Timestamp of when the item was added.

*   **`orders`**: Stores order information placed by users.
    *   `order_id`: Primary Key, auto-incrementing.
    *   `user_id`: Foreign Key referencing `users.user_id`.
    *   `order_date`: Timestamp of when the order was placed.
    *   `total_amount`: Total monetary value of the order.
    *   `status`: Current status of the order (e.g., pending, shipped, completed).

*   **`order_items`**: A junction table linking orders to items, representing the specific items included in each order.
    *   `order_item_id`: Primary Key, auto-incrementing.
    *   `order_id`: Foreign Key referencing `orders.order_id`.
    *   `item_id`: Foreign Key referencing `items.item_id`.
    *   `quantity`: Number of units of the item in the order.
    *   `price_at_purchase`: The price of the item at the time the order was placed.

The script also creates indexes on frequently queried columns to improve database performance and inserts sample data into each table to provide a ready-to-use dataset.
