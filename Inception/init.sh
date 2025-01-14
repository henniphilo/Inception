#!/bin/bash

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Base directory for data
DATA_DIR="/home/hwiemann/data"

# Function to create directory
create_directory() {
  local dir="$1"
  if [ -d "$dir" ]; then
    rm -fr "$dir" && echo "Directory $dir removed." || exit 1
  fi
  mkdir -p "$dir" && chmod 755 "$dir" && echo "Directory $dir created." || exit 1
}

# Create directories
# Avoid overwriting existing WordPress files
if [ ! -d "$DATA_DIR/wordpress/wp-content" ]; then
    echo "Initializing WordPress data..."
    create_directory "$DATA_DIR/wordpress"
else
    echo "WordPress data already exists, skipping initialization."
fi
create_directory "$DATA_DIR/mariadb"

# Check if .env file exists
ENV_FILE="./.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found"
  exit 1
fi

echo ".env file found."