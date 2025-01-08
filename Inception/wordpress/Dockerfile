FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-bcmath \
    curl \
    iputils-ping \
    iproute2 \
    net-tools \
    default-mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the directory for WordPress files
RUN mkdir -p /var/www/html

# Download and install WordPress
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
    && rm latest.tar.gz

# Configure php-fpm to listen on port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Redirect PHP-FPM error log to stderr
RUN sed -i 's|error_log = /var/log/php7.4-fpm.log|error_log = /proc/self/fd/2|g' /etc/php/7.4/fpm/php-fpm.conf

# Create directory for php-fpm socket
RUN mkdir -p /run/php

# Create log directory and set permissions
RUN mkdir -p /var/log/php7.4-fpm && \
    chown -R www-data:www-data /var/log/php7.4-fpm

# Copy custom entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set proper ownership
RUN chown -R www-data:www-data /var/www/html /run/php /entrypoint.sh

# Switch to www-data user
USER www-data

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]
