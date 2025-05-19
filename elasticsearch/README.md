# Docker ElasticSearch Setup

This project provides a Docker setup for running an Elasticsearch container with initialization scripts.

## Prerequisites

- Docker installed on your system.
- `bash` (e.g., Git Bash or WSL on Windows)
- `curl`
- Standard Unix utilities like `grep`, `sed`, `wc` (usually available by default).

## Setup

1. Navigate to the `elasticsearch` directory:
   ```bash
   cd elasticsearch
   ```

2. Run the docker-compose file to start the Elasticsearch container:
   ```bash
   docker-compose up -d
   ```

   Alternatively, from the project root:
   ```bash
   docker-compose -f elasticsearch/docker-compose.yml up -d
   ```

   This command will:
   - Run the container in detached mode (`-d`).
   - Use the image `elasticsearch:9.0.1`.
   - Map port 9200 on the host to port 9200 in the container (for the HTTP API).
   - Map port 9300 on the host to port 9300 in the container (for inter-node communication).
   - Set the `discovery.type` environment variable to `single-node` for a single-node cluster.
   - Set `xpack.security.enabled=false` to disable security features (like requiring HTTPS) for simpler local development. **Note:** This is not recommended for production environments.

3. Initialize the data:
   ```bash
   bash elasticsearch/init.sh
   ```
   
   The script will:
   - Wait for Elasticsearch to become available at `http://localhost:9200`.
   - Create indices: `users`, `categories`, `items`, and `orders`.
   - Define mappings for each index.
   - Bulk insert sample data into the indices.

   You should see output indicating the creation of mappings and the result of the bulk data insertion.

## Verifying the Data

You can use the provided test script to verify that the data was loaded correctly:

```bash
bash elasticsearch/test.sh
```

The script will perform checks such as:
- Verifying that all expected indices (`users`, `categories`, `items`, `orders`) exist.
- Checking if each index contains the correct number of documents.
- Validating specific data points, like the number of nested items in an order.

The script will output a summary of passed and failed checks.

Note: Make sure to run this after the container has fully started and the initialization process has completed.

## Cleanup

To stop and remove the Elasticsearch container, run the following command in the `elasticsearch` directory:

```bash
docker-compose down
```

## Customization

You can customize the Elasticsearch configuration by modifying the `elasticsearch/docker-compose.yml` file or by setting environment variables. Refer to the official Elasticsearch Docker documentation for more details: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

## Building the image (if using a custom Dockerfile)

If you have a custom Dockerfile, you can build the image using:
```bash
docker build -t my-elasticsearch-image .
```

And then run it with:

```bash
docker run -d -p 9200:9200 -p 9300:9300 my-elasticsearch-image
```

## Elasticsearch Initialization (`elasticsearch/init.sh`)

The `elasticsearch/init.sh` script sets up a sample e-commerce database schema in Elasticsearch. It creates and populates the following indices:

*   **`users`**: Stores user information, including username, email, and hashed password.
    *   Fields include: `user_id`, `username`, `email`, `password_hash`, `created_at`.

*   **`categories`**: Stores product categories.
    *   Fields include: `category_id`, `category_name`.

*   **`items`**: Stores information about individual products.
    *   Fields include: `item_id`, `item_name`, `description`, `price`, `category_id`, `stock_quantity`, `created_at`.

*   **`orders`**: Stores order information placed by users.
    *   Fields include: `order_id`, `user_id`, `order_date`, `total_amount`, `status`, and nested `items` containing the ordered products.

The script defines appropriate mappings for each index to ensure proper data types and indexing behavior, and inserts sample data into each index to provide a ready-to-use dataset.

You can access the Elasticsearch API at `http://localhost:9200` to interact with these indices directly.
