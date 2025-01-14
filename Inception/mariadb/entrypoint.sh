#!/bin/bash
 echo "-------> WELCOME TO THE MARIADB ENTRYPOINT <----------"
 echo "-------> WELCOME AGAIN <----------"

# Ensure the socket directory exists and has the correct permissions
mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/
chmod 755 /run/mysqld/

# Ensure the data directory has correct permissions
chown -R mysql:mysql /var/lib/mysql
chmod 755 /var/lib/mysql

# Check if the database needs to be initialized
if [ -d "/var/lib/mysql/mysql" ]; then
    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB server
    mysqld_safe --datadir='/var/lib/mysql' &
    until mysqladmin ping -uroot --silent; do
        echo "Waiting for MariaDB to start..."
        sleep 1
    done

     # Set root password and create database and user
    # mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('roothenni42');"
    # echo "trying to create Database"
    # mysql -uroot -p"roothenni42" -e "CREATE DATABASE IF NOT EXISTS \`wordpress\`;"
    # mysql -uroot -p"roothenni42" -e "CREATE USER IF NOT EXISTS 'henni42'@'%' IDENTIFIED BY 'henni42';"
    # mysql -uroot -p"roothenni42" -e "GRANT ALL PRIVILEGES ON \`wordpress\`.* TO 'henni42'@'%';"

    # mysql -uroot -p"roothenni42" -e "FLUSH PRIVILEGES;"
    # # Stop the temporary MariaDB instance
    # mysqladmin -uroot -p"roothenni42" shutdown

    # # Set root password and create database and user
    mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
    echo "trying to create Database $MYSQL_DATABASE hihi"

    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"

    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

    #Stop the temporary MariaDB instance
    mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
    echo " created Database"
fi

# Start MariaDB in the foreground
exec mysqld_safe --datadir='/var/lib/mysql'
