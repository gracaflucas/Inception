#!/bin/bash
set -e

# Load DB credentials from Docker secrets
if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "ERROR: db_password secret not found!"
    exit 1
fi

DB_NAME=${MYSQL_DATABASE:-wordpress}
DB_USER=${MYSQL_USER:-root}
DB_HOST=${MYSQL_HOST:-mariadb}

# Admin credentials (read from secrets if available, else fall back to env)
if [ -f "/run/secrets/db_root_password" ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/db_root_password)
else
    WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-admin}
fi

WP_ADMIN_USER=${WP_ADMIN_USER:-admin}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}
WP_TITLE=${WP_TITLE:-"My WordPress Site"}
DOMAIN_NAME=${DOMAIN_NAME:-localhost}

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "  MariaDB not ready yet, retrying..."
    sleep 2
done
echo "MariaDB is ready!"

WP_DIR=/var/www/wordpress

# Step 1: Create wp-config.php if it doesn't exist
if [ ! -f "$WP_DIR/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --allow-root \
        --path="$WP_DIR" \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST"
    echo "wp-config.php created."
fi

# Step 2: Install WordPress only if not already installed
if ! wp core is-installed --allow-root --path="$WP_DIR" 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --allow-root \
        --path="$WP_DIR" \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
    echo "WordPress installed!"

    # Step 3: Create a second non-admin user if env vars are set
    if [ -n "$WP_USER" ] && [ -n "$WP_USER_EMAIL" ]; then
        if [ -f "/run/secrets/db_password" ]; then
            WP_USER_PASSWORD=$(cat /run/secrets/db_password)
        else
            WP_USER_PASSWORD=${WP_USER_PASSWORD:-password}
        fi

        wp user create \
            --allow-root \
            --path="$WP_DIR" \
            "$WP_USER" "$WP_USER_EMAIL" \
            --role=subscriber \
            --user_pass="$WP_USER_PASSWORD"
        echo "Extra user '$WP_USER' created."
    fi
else
    echo "WordPress is already installed, skipping installation."
fi

# Ensure correct permissions
chown -R www-data:www-data "$WP_DIR"

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F

