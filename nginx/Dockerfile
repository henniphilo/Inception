FROM alpine:latest

RUN apk update && apk add nginx openssl

# Selbst signiertes SSL-Zertifikat generieren
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Company/OU=Org/CN=deinlogin.42.fr"

# NGINX-Konfiguration hier einfügen
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

