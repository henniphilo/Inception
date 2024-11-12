FROM alpine:latest

RUN apk update && apk add php7 php7-fpm php7-mysqli php7-json php7-curl && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && mv wordpress /var/www/wordpress

EXPOSE 9000

CMD ["php-fpm7", "-F"]

