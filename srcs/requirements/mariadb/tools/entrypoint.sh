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

DB_NAME=${MYSQL_DATABASE}
DB_USER=${MYSQL_USER}

echo "Starting MariaDB initialization..."
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Clean up stale PID/socket files from a previous run
rm -f /var/lib/mysql/*.pid
rm -f /var/run/mysqld/mysqld.sock
rm -f /var/run/mysqld/mysqld.pid
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

# Track whether this is a brand new database
FRESH_INSTALL=false
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing fresh database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    FRESH_INSTALL=true
fi

# Start MariaDB temporarily for setup
echo "Starting temporary MariaDB instance for setup..."
mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock --datadir=/var/lib/mysql &
pid="$!"

# Wait for MariaDB to be ready
echo "Waiting for temporary MariaDB to be ready..."
for i in $(seq 1 30); do
    if mysqladmin --socket=/var/run/mysqld/mysqld.sock ping --silent 2>/dev/null; then
        echo "Temporary MariaDB is ready!"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: MariaDB failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

if [ "$FRESH_INSTALL" = true ]; then
    # First boot: root has no password yet
    echo "Fresh install detected - running first-time setup..."
    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL
    echo "First-time database setup complete!"
else
    # Subsequent boots: root already has a password, just verify things are in order
    echo "Existing install detected - verifying setup..."
    mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
    echo "Verification complete!"
fi

# Gracefully shut down the temporary instance
echo "Shutting down temporary MariaDB instance..."
mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown

# Wait for it to fully stop
wait "$pid" 2>/dev/null || true
echo "Temporary instance stopped."

sleep 1

# Start MariaDB permanently
echo "Starting MariaDB permanently..."
exec mysqld_safe --datadir=/var/lib/mysql

