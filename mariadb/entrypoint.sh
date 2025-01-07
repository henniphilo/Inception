#!/bin/bash

# set -e

# # Change ownership of data directory
# chown -R mysql:mysql /var/lib/mysql
# chown mysql:mysql /run/mysqld/

# # Initialize MariaDB data directory if it's empty
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql
# fi

# # Start MariaDB in the background as mysql user
# su -s /bin/bash mysql -c "mysqld_safe &"

# # Wait for MariaDB to become available
# until mysqladmin ping -h"localhost" --silent; do
#     sleep 1
# done

# # Create database and user if they don't exist
# mysql -v -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
#     CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
#     CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
#     GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
#     FLUSH PRIVILEGES;
# EOSQL

# # Keep the container running
# exec "$@"



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