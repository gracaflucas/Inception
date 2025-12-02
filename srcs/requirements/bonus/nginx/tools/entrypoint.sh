#!/bin/bash
set -e

echo "Starting Nginx with TLS..."
exec nginx -g "daemon off;"
