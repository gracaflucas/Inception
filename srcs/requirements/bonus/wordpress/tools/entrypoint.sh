#!/bin/bash
set -e

# Load DB credentials from Docker secrets
if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
fi
DB_NAME=${MYSQL_DATABASE:-wordpress}
DB_USER=${MYSQL_USER:-root}
DB_HOST=${MYSQL_HOST:-mariadb}

# Wait for MariaDB
echo "Waiting for MariaDB..."
until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
  sleep 2
done
echo "MariaDB is ready!"

# Wait for Redis
echo "Waiting for Redis..."
until redis-cli -h redis ping >/dev/null 2>&1; do
  sleep 2
done
echo "Redis is ready!"

# Configure WordPress if not already configured
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
    
    # Database configuration
    sed -i "s/database_name_here/$DB_NAME/" /var/www/wordpress/wp-config.php
    sed -i "s/username_here/$DB_USER/" /var/www/wordpress/wp-config.php
    sed -i "s/password_here/$DB_PASSWORD/" /var/www/wordpress/wp-config.php
    sed -i "s/localhost/$DB_HOST/" /var/www/wordpress/wp-config.php
    
    echo "wp-config.php created successfully!"
fi

# Configure Redis cache if not already present
if ! grep -q "WP_REDIS_HOST" /var/www/wordpress/wp-config.php; then
    echo "Configuring Redis cache..."
    # Insert Redis configuration before the "That's all" comment
    sed -i "/That's all, stop editing/i \
/* Redis Cache Configuration */\n\
define('WP_REDIS_HOST', 'redis');\n\
define('WP_REDIS_PORT', 6379);\n\
define('WP_REDIS_TIMEOUT', 1);\n\
define('WP_REDIS_READ_TIMEOUT', 1);\n\
define('WP_REDIS_DATABASE', 0);\n" /var/www/wordpress/wp-config.php
    
    echo "Redis configuration added to wp-config.php!"
fi

# Ensure correct permissions
echo "Setting file permissions..."
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod 755 {} \;
find /var/www/wordpress -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F