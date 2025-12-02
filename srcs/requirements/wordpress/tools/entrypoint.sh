#!/bin/bash
set -e

# Load DB credentials from Docker secrets or environment variables
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

# Configure WordPress if not already configured
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
    sed -i "s/database_name_here/$DB_NAME/" /var/www/wordpress/wp-config.php
    sed -i "s/username_here/$DB_USER/" /var/www/wordpress/wp-config.php
    sed -i "s/password_here/$DB_PASSWORD/" /var/www/wordpress/wp-config.php
    sed -i "s/localhost/$DB_HOST/" /var/www/wordpress/wp-config.php
    echo "Configured wp-config.php"
fi

# Ensure permissions
chown -R www-data:www-data /var/www/wordpress

# Start PHP-FPM in foreground
exec php-fpm7.4 -F


# chown -R www-data:www-data * ( for redis )
# sed -i "41 i define( 'WP_REDIS_HOST', 'redis' );\ndefine( 'WP_REDIS_PORT', '6379' );\n" wp-config.php


# #!/bin/bash
# set -e

# # Adjust permissions
# chown -R www-data:www-data /var/www/html

# # Start PHP-FPM in foreground
# exec php-fpm7.4 -F
