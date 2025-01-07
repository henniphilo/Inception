#!/bin/bash

# Wait for MariaDB to be ready
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    sleep 1
done

# Configure wp-config.php if it doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
fi

# Start php-fpm
exec "$@"

