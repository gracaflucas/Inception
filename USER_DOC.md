# User Documentation

## Overview

This document explains how to use and interact with the Inception infrastructure as an end user or administrator.

The stack provides:

* A secure HTTPS website powered by WordPress
* A MariaDB database backend
* A single HTTPS entry point via NGINX

---

## Starting and Stopping the Project

From the root of the repository:

```bash
make
```

To stop the running containers:

```bash
make down
```

---

## Accessing the Website

1. Ensure the domain `login.42.fr` is mapped to the local machine in `/etc/hosts`
2. Open a browser and go to:

```
https://login.42.fr
```

The connection is secured using TLS 1.2 or TLS 1.3.

---

## WordPress Administration Panel

The WordPress admin interface is available at:

```
https://login.42.fr/wp-admin
```

Administrator credentials are defined during the initial WordPress setup using environment variables and secrets.

---

## Credentials Management

* Configuration variables are stored in `srcs/.env`
* Sensitive data (database passwords, credentials) are stored as Docker secrets
* Secrets are **not** tracked by Git and must be created locally

Never commit credentials to the repository.

---

## Verifying Services Status

To check running containers:

```bash
docker ps
```

To inspect logs:

```bash
docker logs <container_name>
```

Expected running services:

* nginx
* wordpress
* mariadb

---

## Data Persistence

* WordPress files are stored in a Docker volume
* Database data is stored in a separate Docker volume

Stopping or restarting containers will **not** delete data.

