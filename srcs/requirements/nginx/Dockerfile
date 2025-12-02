FROM debian:bullseye

# Install nginx and openssl
RUN apt-get update && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Create SSL directory and generate self-signed certificate
RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/nginx.key \
       -out /etc/nginx/ssl/nginx.crt \
       -subj "/C=US/ST=State/L=City/O=42School/OU=Student/CN=${DOMAIN_NAME}"

# Copy nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy entrypoint
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# FROM debian:bullseye

# # Install NGINX and OpenSSL
# RUN apt-get update && apt-get install -y \
#     nginx openssl \
#     && rm -rf /var/lib/apt/lists/*

# # Create SSL directory
# RUN mkdir -p /etc/nginx/ssl

# # Copy configuration and entrypoint
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# EXPOSE 443

# ENTRYPOINT ["/entrypoint.sh"]

