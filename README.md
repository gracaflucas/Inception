*This project has been created as part of the 42 curriculum by lufiguei.*

# Inception

## Description

**Inception** is a system administration and DevOps–oriented project whose goal is to design and deploy a small, secure web infrastructure using **Docker** and **Docker Compose**, all running inside a **virtual machine**.

The project focuses on understanding how services are isolated, networked, secured, and orchestrated using containers. Instead of relying on pre-built images, every service is built manually from minimal base images (Debian or Alpine), following best practices for security, performance, and maintainability.

The final infrastructure consists of:

* An **NGINX** container acting as the single entry point, serving HTTPS only (TLS 1.2 / 1.3)
* A **WordPress** container running with **php-fpm** (no embedded web server)
* A **MariaDB** container for persistent database storage
* Dedicated **Docker volumes** for WordPress files and database data
* A private **Docker network** connecting all services

---

## Project Architecture Overview

* All services run in **separate containers**
* Containers are orchestrated using **docker-compose**
* The infrastructure is launched and managed through a **Makefile**
* Secrets and credentials are never hardcoded and are managed using environment variables and Docker secrets

The domain name `login.42.fr` is locally mapped to the virtual machine in order to access the website via HTTPS.

---

## Instructions

### Prerequisites

* Linux-based virtual machine (Debian 12 – Bookworm)
* Docker
* Docker Compose plugin
* Make

### Build and Run

From the root of the repository:

```bash
make
```

This command will:

1. Build all Docker images
2. Create volumes and network
3. Start the infrastructure using Docker Compose

To stop the project:

```bash
make down
```

To completely clean containers, images, and volumes:

```bash
make fclean
```

---

## Design Choices and Comparisons

### Virtual Machines vs Docker

* **Virtual Machines** virtualize entire operating systems and are heavier in terms of resource usage.
* **Docker containers** share the host kernel, are lightweight, start faster, and are better suited for microservice architectures.

This project uses a **VM for isolation**, and **Docker inside it** for service orchestration.

### Secrets vs Environment Variables

* **Environment variables** are suitable for non-sensitive configuration values.
* **Docker secrets** are designed to securely store sensitive data such as passwords and credentials.

This project uses a `.env` file for configuration and Docker secrets for confidential information.

### Docker Network vs Host Network

* **Host networking** removes isolation and exposes services directly on the host.
* **Docker networks** provide controlled communication between containers while keeping services isolated.

A dedicated Docker network is used to respect isolation and security requirements.

### Docker Volumes vs Bind Mounts

* **Bind mounts** depend on host paths and can cause portability issues.
* **Docker volumes** are managed by Docker, portable, and safer for persistent data.

Docker volumes are used to persist WordPress files and database data.

---

## Comandos para mudar para 8443:

```bash
# Altera o docker-compose.yml para "8443:443"
docker compose -f srcs/docker-compose.yml up -d nginx
docker exec -it wordpress wp option update home 'https://lufiguei.42.fr:8443' --allow-root
docker exec -it wordpress wp option update siteurl 'https://lufiguei.42.fr:8443' --allow-root
```

## Comandos para voltar para 443:

```bash
# Altera o docker-compose.yml de volta para "443:443"
docker compose -f srcs/docker-compose.yml up -d nginx
docker exec -it wordpress wp option update home 'https://lufiguei.42.fr' --allow-root
docker exec -it wordpress wp option update siteurl 'https://lufiguei.42.fr' --allow-root
```

## Entrar no banco de dados (Com a senha do secrets/pass_mariadb.txt)
docker exec -it mariadb mysql -u root -p

## checar tsl
openssl s_client -connect google.com:443 -tls1_2

## Resources

### Technical References

* Docker documentation
* Docker Compose documentation
* Debian official documentation
* NGINX documentation
* WordPress and MariaDB documentation

### AI Usage Disclosure

AI tools were used during this project to:

* Clarify Docker and Docker Compose concepts
* Validate architectural decisions
* Assist with documentation structure and wording

All implementation, configuration, and debugging decisions were made and validated by the project author.

---

## Additional Documentation

* `USER_DOC.md` — User and administrator guide
* `DEV_DOC.md` — Developer and maintenance documentation

