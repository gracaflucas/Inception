# Default target
all: up

# Build mandatory Docker images
build:
	docker compose -f srcs/docker-compose.yml build

# Start mandatory services
up: build
	docker compose -f srcs/docker-compose.yml up -d

# Stop mandatory services
down:
	docker compose -f srcs/docker-compose.yml down

# Remove mandatory volumes
clean: down
	docker volume rm srcs_wordpress_data srcs_mariadb_data || true
	docker volume rm srcs_bonus_wordpress_data srcs_bonus_mariadb_data srcs_redis_data || true

# Full cleanup for mandatory
fclean: clean
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans
	docker compose -f srcs/requirements/bonus/docker-compose.yml down --rmi all --volumes --remove-orphans

# Rebuild everything from scratch (mandatory)
re: fclean all

# Show logs for mandatory services
logs:
	docker compose -f srcs/docker-compose.yml logs -f


# ===== BONUS RULES =====

check:
	bash srcs/requirements/bonus/check_services.sh

# Build bonus Docker images
bonus-build:
	docker compose -f srcs/requirements/bonus/docker-compose.yml build

# Start bonus services
bonus-up: bonus-build
	docker compose -f srcs/requirements/bonus/docker-compose.yml up -d

# Stop bonus services
bonus-down:
	docker compose -f srcs/requirements/bonus/docker-compose.yml down

# Rebuild everything from scratch (bonus)
bonus-re: bonus-fclean bonus-up

# Show logs for bonus services
bonus-logs:
	docker compose -f srcs/requirements/bonus/docker-compose.yml logs -f

#docker ps
#docker exec -it worpress sh
#docker compose down --rmi all 