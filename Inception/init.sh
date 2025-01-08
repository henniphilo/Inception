#!/bin/bash

# CREATE WORDPRESS DIRECTORY
DIR="../data/wordpress"
if [ -d "$DIR" ]; then
  rm -fr "$DIR"
  echo -e "Directory $DIR removed."
fi
mkdir -p "$DIR"
echo -e "Directory $DIR created."

# CREATE MARIADB DIRECTORY
DIR="../data/mariadb"
if [ -d "$DIR" ]; then
  rm -fr "$DIR"
  echo -e "Directory $DIR removed."
fi
mkdir -p "$DIR"
echo -e "Directory $DIR created."

# CREATE ENV VARIABLES
ENV_FILE="./.env"
if [ -f "$ENV_FILE" ]; then
  rm -f "$ENV_FILE"
  echo -e ".env file removed."
fi
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"  # Set appropriate permissions

cat << EOF > "$ENV_FILE"
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=henni42
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_PASSWORD=henni42
MYSQL_ROOT_PASSWORD=roothenni42
MYSQL_DATABASE=wordpress
MYSQL_USER=henni42
MYSQL_PASSWORD=henni42
EOF

echo -e ".env file created."

# Verify the file was created
if [ -f "$ENV_FILE" ]; then
  echo "Contents of .env file:"
  cat "$ENV_FILE"
else
  echo "Failed to create .env file"
fi