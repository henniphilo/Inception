FROM debian:bullseye-slim

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Create directories for server blocks and SSL
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/ssl

# Copy the NGINX configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Copy SSL certificate and key
COPY ssl/hwiemann.42.fr.crt /etc/nginx/ssl/hwiemann.42.fr.crt
COPY ssl/hwiemann.42.fr.key /etc/nginx/ssl/hwiemann.42.fr.key

# Generate DHParam file
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Create a symbolic link to enable the site, only if it doesn't exist
RUN if [ ! -L /etc/nginx/sites-enabled/default ]; then ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default; fi

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
