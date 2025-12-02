#!/bin/bash
echo "Checking service status..."

# Check MariaDB
if docker exec mariadb mysql -uroot -p"$DB_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null; then
    echo "✅ MariaDB is online"
else
    echo "❌ MariaDB is not responding"
fi

# Check WordPress
if curl -s --head http://localhost:8000 | head -n 1 | grep "200\|301" &>/dev/null; then
    echo "✅ WordPress is online"
else
    echo "❌ WordPress is not responding"
fi

# Check Nginx
if curl -k -s --head https://localhost:443 | head -n 1 | grep "200\|301" &>/dev/null; then
    echo "✅ Nginx is online"
else
    echo "❌ Nginx is not responding"
fi

# Check Redis
if docker exec srcs-redis redis-cli ping | grep PONG &>/dev/null; then
    echo "✅ Redis is online"
else
    echo "❌ Redis is not responding"
fi
