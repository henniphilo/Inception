#!/bin/bash

# Ensure the socket directory exists and has the correct permissions
mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/
chmod 755 /run/mysqld/

# Start MariaDB server directly
mysqld_safe --datadir='/var/lib/mysql' &
until mysqladmin ping -uroot -p$"$MYSQL_ROOT_PASSWORD" --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

# Check if database already exists
DB_EXISTS=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE'" | grep "$MYSQL_DATABASE" > /dev/null; echo "$?")

# Create database if it does not exist 
if [ "$DB_EXISTS" -eq 1 ]; then
    echo "Database does not exist. Creating database and user..." >> /var/log/mariadb_env_vars.log
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`" || { echo 'Failed to create database' >> /var/log/mariadb_env_vars.log; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'" || { echo 'Failed to create user' >> /var/log/mariadb_env_vars.log; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%'" || { echo 'Failed to grant privileges' >> /var/log/mariadb_env_vars.log; exit 1; }
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" || { echo 'Failed to flush privileges' >> /var/log/mariadb_env_vars.log; exit 1; }
    echo "Database and user created successfully." >> /var/log/mariadb_env_vars.log
else
    echo "Database already exists. Skipping creation." >> /var/log/mariadb_env_vars.log
fi

# Stop the MariaDB service started by the service command
mysqladmin shutdown -uroot -p"$MYSQL_ROOT_PASSWORD"

# Start MariaDB in the foreground to keep the container running
exec mysqld_safe --datadir='/var/lib/mysql'