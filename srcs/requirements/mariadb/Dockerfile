FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


# FROM debian:bullseye

# # Install MariaDB server
# RUN apt-get update && apt-get install -y mariadb-server \
#     && rm -rf /var/lib/apt/lists/*

# # Create directory for database
# RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# # Copy custom config (optional)
# COPY my.cnf /etc/mysql/my.cnf

# # Copy entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# EXPOSE 3306

# VOLUME ["/var/lib/mysql"]

# ENTRYPOINT ["/entrypoint.sh"]
