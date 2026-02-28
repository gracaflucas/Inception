# Default target
all: up

# Build Docker images
build:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env build

# Start services
up: build
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d
	@echo ""
	@echo "✓ Services started!"
	@echo "Access: https://localhost"

# Stop services
down:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down

# Remove volumes
clean: down
	docker volume rm srcs_wordpress_data srcs_mariadb_data 2>/dev/null || true

# Full cleanup
fclean: clean
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --rmi all --volumes --remove-orphans
	docker system prune -f

# Rebuild everything from scratch
re: fclean all

# Show logs
logs:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f

# Show container status
status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Help
help:
	@echo "Available targets:"
	@echo "  make up      - Build and start services"
	@echo "  make down    - Stop services"
	@echo "  make re      - Full rebuild from scratch"
	@echo "  make clean   - Stop and remove volumes"
	@echo "  make fclean  - Full cleanup (images + volumes + orphans)"
	@echo "  make logs    - Follow logs"
	@echo "  make status  - Show running containers"

.PHONY: all build up down clean fclean re logs status help
