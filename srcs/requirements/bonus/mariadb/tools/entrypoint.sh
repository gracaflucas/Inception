#!/bin/bash
set -e

# Secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Env vars (from .env file)
DB_NAME=${MYSQL_DATABASE}
DB_USER=${MYSQL_USER}

# Start MariaDB in safe mode for initialization
mysqld_safe --skip-networking &
pid="$!"

# Wait for server startup
until mysqladmin ping >/dev/null 2>&1; do
  echo "Waiting for MariaDB to be ready..."
  sleep 2
done

# Create DB + user if not exists
mysql -uroot <<-EOSQL
  CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
  CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
  GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
  ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
  FLUSH PRIVILEGES;
EOSQL

# Shutdown temporary MariaDB
mysqladmin -uroot -p"${DB_ROOT_PASSWORD}" shutdown

# Exec to run mariadb as PID 1
exec mysqld_safe
