
FROM debian:bullseye-slim

# Install MariaDB and other necessary packages
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY my.cnf /etc/mysql/my.cnf
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh

# Set permissions for the entrypoint script
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

# Set up the data directory
RUN mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

# Expose the MySQL port
EXPOSE 3306

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

# Set the default command
CMD ["mysqld"]
