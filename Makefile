# Default target
all: up

# Build Docker images
build:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env build

# Start services
up: build
	@mkdir -p /home/lufiguei/data/mariadb
	@mkdir -p /home/lufiguei/data/wordpress
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d
	@echo ""
	@echo "✓ Services started!"
	@echo "Access: https://localhost"

# Stop services
down:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down

# Remove images only
clean: down
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --rmi all
	docker system prune -f

# Full cleanup - remove images AND volumes
fclean: down
	@sudo rm -rf /home/lufiguei/data/mariadb
	@sudo rm -rf /home/lufiguei/data/wordpress
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down --rmi all --volumes --remove-orphans
	docker system prune -af --volumes

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
	@echo "  make down    - Stop services (data persists)"
	@echo "  make re      - Full rebuild from scratch"
	@echo "  make clean   - Stop and remove images only (data persists)"
	@echo "  make fclean  - Full cleanup (images + volumes + data)"
	@echo "  make logs    - Follow logs"
	@echo "  make status  - Show running containers"

.PHONY: all build up down clean fclean re logs status help

