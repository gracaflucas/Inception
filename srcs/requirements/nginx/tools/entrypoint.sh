#!/bin/bash
set -e

echo "Starting Nginx with TLS..."
exec nginx -g "daemon off;"


# #!/bin/bash
# set -e

# # Generate self-signed cert if not exists
# if [ ! -f /etc/nginx/ssl/server.crt ]; then
#     openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
#         -keyout /etc/nginx/ssl/server.key \
#         -out /etc/nginx/ssl/server.crt \
#         -subj "/C=US/ST=Default/L=Default/O=Default/CN=localhost"
# fi

# exec nginx -g "daemon off;"
