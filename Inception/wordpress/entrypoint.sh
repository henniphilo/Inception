#!/bin/bash

# Change to the WordPress directory
cd /var/www/html

# Function to wait for MariaDB
wait_for_mariadb() {
    max_tries=30
    count=0
    while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
        sleep 1
        count=$((count + 1))
        if [ $count -ge $max_tries ]; then
            echo "Error: MariaDB did not become ready in time"
            exit 1
        fi
    done
    echo "MariaDB is ready"
}

# Function to setup WordPress and create users
setup_wordpress() {
    # Clean existing files
    rm -rf /var/www/html/*

    # Download WordPress
    /usr/local/bin/wp core download --allow-root || { echo "Failed to download WordPress"; exit 1; }

    # Create wp-config.php
    /usr/local/bin/wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --allow-root || { echo "Failed to create wp-config.php"; exit 1; }

    # Install WordPress
    /usr/local/bin/wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --allow-root || { echo "Failed to install WordPress"; exit 1; }

    # Create second user (non-admin)
    /usr/local/bin/wp user create "$WORDPRESS_SECOND_USER" "$WORDPRESS_SECOND_EMAIL" --role=editor --user_pass="$WORDPRESS_SECOND_PASSWORD" --allow-root --debug || { echo "Failed to create second user"; exit 1; }
    /usr/local/bin/wp user list --allow-root

    # Set correct permissions
    chown -R www-data:www-data /var/www/html
}

# Wait for MariaDB to be ready
wait_for_mariadb

# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
    setup_wordpress
else
    echo "WordPress is already installed."
fi

if /usr/local/bin/wp user get "$WORDPRESS_SECOND_USER" --field=ID --allow-root 2>/dev/null; then
    echo "User $WORDPRESS_SECOND_USER already exists."
else
    /usr/local/bin/wp user create "$WORDPRESS_SECOND_USER" "$WORDPRESS_SECOND_EMAIL" --role=editor --user_pass="$WORDPRESS_SECOND_PASSWORD" --allow-root || { echo "Failed to create second user"; exit 1; }
fi

# Start PHP-FPM
exec php-fpm7.4 -F