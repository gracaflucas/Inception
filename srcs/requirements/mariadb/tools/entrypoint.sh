#!/bin/bash
set -e

# Read secrets
if [ -f "/run/secrets/db_root_password" ]; then
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
else
    echo "ERROR: db_root_password secret not found!"
    exit 1
fi

if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "ERROR: db_password secret not found!"
    exit 1
fi

# Env vars
DB_NAME=${MYSQL_DATABASE}
DB_USER=${MYSQL_USER}

echo "Starting MariaDB initialization..."
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Initialize database if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB temporarily for setup
echo "Starting temporary MariaDB..."
mysqld_safe --skip-networking --datadir=/var/lib/mysql &
pid="$!"

# Wait for MariaDB to start
echo "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "MariaDB is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "ERROR: MariaDB failed to start"
        exit 1
    fi
    sleep 1
done

# Create database and user
echo "Creating database and user..."
mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

echo "Database setup complete!"

# Shutdown temporary MariaDB
echo "Shutting down temporary instance..."
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

# Wait for shutdown
wait $pid

# Start MariaDB normally
echo "Starting MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql