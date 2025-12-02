FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql curl tar \
    && rm -rf /var/lib/apt/lists/*

# Create the target directory
RUN mkdir -p /var/www/wordpress

# Download and extract WordPress
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf wordpress.tar.gz -C /var/www/wordpress --strip-components=1 \
    && rm wordpress.tar.gz

# Ensure www-data owns WordPress files
RUN chown -R www-data:www-data /var/www/wordpress

RUN apt-get update && apt-get install -y \
    php-redis \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to run in foreground
RUN sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/*/fpm/php-fpm.conf

# Copy custom PHP-FPM pool config
COPY conf/www.conf /etc/php/*/fpm/pool.d/www.conf

# Copy entrypoint
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
