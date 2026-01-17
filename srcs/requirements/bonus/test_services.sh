#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================="
echo "  INCEPTION - TEST SUITE"
echo "=================================="
echo ""

# Function to check service
check_service() {
    local service_name=$1
    local test_command=$2
    local success_msg=$3
    
    echo -n "Testing ${service_name}... "
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ OK${NC} - $success_msg"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Container Status
echo "=== CONTAINER STATUS ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "mariadb|wordpress|nginx|redis|ftp|adminer|portainer|static"
echo ""

# Test MariaDB
echo "=== TESTING MARIADB ==="
check_service "MariaDB Connection" \
    "docker exec mariadb mysqladmin ping -h localhost" \
    "Database responding"

check_service "MariaDB Database" \
    "docker exec mariadb mysql -uroot -p\$(cat secrets/db_root_password.txt) -e 'USE wordpress;'" \
    "WordPress database exists"
echo ""

# Test WordPress
echo "=== TESTING WORDPRESS ==="
check_service "WordPress PHP" \
    "docker exec wordpress php -v" \
    "PHP installed"

check_service "WordPress Files" \
    "docker exec wordpress test -f /var/www/wordpress/wp-config.php" \
    "wp-config.php exists"

check_service "WordPress DB Connection" \
    "docker exec wordpress mysql -h mariadb -u wp_user -p\$(cat secrets/db_password.txt) -e 'SELECT 1;'" \
    "Connected to database"
echo ""

# Test Redis
echo "=== TESTING REDIS ==="
check_service "Redis" \
    "docker exec redis redis-cli ping" \
    "Redis responding (PONG)"

check_service "Redis from WordPress" \
    "docker exec wordpress redis-cli -h redis ping" \
    "WordPress reaches Redis"
echo ""

# Test Nginx
echo "=== TESTING NGINX ==="
check_service "Nginx HTTPS" \
    "curl -k -s -o /dev/null -w '%{http_code}' https://localhost:443 | grep -E '200|301|302'" \
    "Serving content"

check_service "Nginx SSL" \
    "echo | openssl s_client -connect localhost:443 2>/dev/null | grep 'Verify return code'" \
    "SSL certificate present"
echo ""

# Test FTP
echo "=== TESTING FTP ==="
check_service "FTP Port" \
    "nc -zv localhost 21" \
    "Port 21 open"
echo ""

# Test Adminer
echo "=== TESTING ADMINER ==="
check_service "Adminer" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:8081 | grep 200" \
    "Accessible on :8081"
echo ""

# Test Portainer
echo "=== TESTING PORTAINER ==="
check_service "Portainer" \
    "curl -k -s -o /dev/null -w '%{http_code}' https://localhost:9443 | grep 200" \
    "Accessible on :9443"
echo ""

# Test Static Site
echo "=== TESTING STATIC SITE ==="
check_service "Static Site" \
    "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 | grep 200" \
    "Accessible on :8080"
echo ""

echo "=================================="
echo "  TESTS COMPLETED"
echo "=================================="
echo ""
echo -e "${YELLOW}Manual checks:${NC}"
echo "1. https://localhost - WordPress"
echo "2. http://localhost:8080 - Portfolio"
echo "3. http://localhost:8081 - Adminer"
echo "4. https://localhost:9443 - Portainer"
echo "5. ftp wpuser@localhost - FTP"