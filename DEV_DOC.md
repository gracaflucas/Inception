# Developer Documentation

## Purpose

This document describes how to set up, build, run, and maintain the Inception project from a developer or administrator perspective.

---

## Environment Setup

### Prerequisites

* Debian 12 (Bookworm) virtual machine
* Docker (installed from official repository)
* Docker Compose plugin
* Make

### Required Files

Before building the project, ensure the following exist:

* `srcs/.env`
* `secrets/` directory containing required secret files

Secrets must be created locally and ignored by Git.

---

## Project Structure

Key directories:

* `srcs/` — Docker Compose file and environment configuration
* `requirements/` — One directory per service, each with its own Dockerfile
* `secrets/` — Sensitive credentials stored as Docker secrets

---

## Build and Launch

To build images and start containers:

```bash
make
```

To stop containers:

```bash
make down
```

To remove containers, images, volumes, and network:

```bash
make fclean
```

---

## Managing Containers and Volumes

Common commands:

```bash
docker ps
docker images
docker volume ls
docker network ls
```

To inspect a specific container:

```bash
docker inspect <container_name>
```

---

## Data Persistence

Persistent data is stored in Docker volumes mounted to:

```
/home/<login>/data
```

This includes:

* MariaDB database files
* WordPress website files

Deleting containers does not remove volumes unless explicitly specified.

---

## Debugging

* Use `docker logs` to inspect service output
* Use `docker exec -it <container> sh` for interactive debugging (when appropriate)
* Verify network connectivity using container names as DNS hosts

---

## Notes for Maintenance

* Base images are pinned to `debian:bookworm` (no `latest` tag)
* Each container runs a single main process (PID 1 best practices)
* No infinite loops or hacky keep-alive commands are used

