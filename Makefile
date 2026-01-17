# Default target
all: up

# Build mandatory Docker images
build:
	docker compose -f srcs/docker-compose.yml build

# Start mandatory services
up: build
	docker compose -f srcs/docker-compose.yml up -d
	@echo ""
	@echo "✓ Mandatory services started!"
	@echo "Access: https://localhost"

# Stop mandatory services
down:
	docker compose -f srcs/docker-compose.yml down

# Remove mandatory volumes
clean: down
	docker volume rm srcs_wordpress_data srcs_mariadb_data || true

# Full cleanup for mandatory
fclean: clean
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

# Rebuild everything from scratch (mandatory)
re: fclean all

# Show logs for mandatory services
logs:
	docker compose -f srcs/docker-compose.yml logs -f

# ===== BONUS RULES =====

# Build bonus Docker images
bonus-build:
	docker compose -f srcs/requirements/bonus/docker-compose.yml build

# Start bonus services
bonus-up: bonus-build
	docker compose -f srcs/requirements/bonus/docker-compose.yml up -d
	@echo ""
	@echo "✓ All services started!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📋 ACCESS POINTS:"
	@echo "  WordPress:    https://localhost"
	@echo "  Static Site:  http://localhost:8080"
	@echo "  Adminer:      http://localhost:8081"
	@echo "  Portainer:    https://localhost:9443"
	@echo "  FTP:          ftp://wpuser:wppass@localhost:21"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Run 'make bonus-test' to verify"

# Stop bonus services
bonus-down:
	docker compose -f srcs/requirements/bonus/docker-compose.yml down

# Clean bonus volumes
bonus-clean: bonus-down
	docker volume rm bonus_wordpress_data bonus_mariadb_data bonus_redis_data bonus_portainer_data || true

# Full cleanup for bonus
bonus-fclean: bonus-clean
	docker compose -f srcs/requirements/bonus/docker-compose.yml down --rmi all --volumes --remove-orphans

# Rebuild bonus from scratch
bonus-re: bonus-fclean bonus-up

# Show bonus logs
bonus-logs:
	docker compose -f srcs/requirements/bonus/docker-compose.yml logs -f

# Test bonus services
bonus-test:
	@bash srcs/requirements/bonus/test_services.sh

# Quick check
bonus-check:
	@echo "Quick check..."
	@docker ps --filter "status=running" --format "{{.Names}}" | grep -E "mariadb|wordpress|nginx|redis|ftp|adminer|portainer|static" | wc -l | xargs -I {} echo "{} services running (expected: 8)"
	@curl -k -s -o /dev/null -w "Nginx: %{http_code}\n" https://localhost:443
	@curl -s -o /dev/null -w "Adminer: %{http_code}\n" http://localhost:8081
	@curl -s -o /dev/null -w "Static: %{http_code}\n" http://localhost:8080

# Container status
bonus-status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|mariadb|wordpress|nginx|redis|ftp|adminer|portainer|static"

# Help
help:
	@echo "Available targets:"
	@echo "  make up              - Start mandatory services"
	@echo "  make down            - Stop mandatory services"
	@echo "  make logs            - Show mandatory logs"
	@echo "  make bonus-up        - Start all services (bonus)"
	@echo "  make bonus-down      - Stop bonus services"
	@echo "  make bonus-test      - Run complete test suite"
	@echo "  make bonus-check     - Quick health check"
	@echo "  make bonus-status    - Show container status"
	@echo "  make bonus-logs      - Show bonus logs"
	@echo "  make bonus-re        - Rebuild from scratch"

.PHONY: all build up down clean fclean re logs \
        bonus-build bonus-up bonus-down bonus-clean bonus-fclean bonus-re \
        bonus-logs bonus-test bonus-status bonus-check help