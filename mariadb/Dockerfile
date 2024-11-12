FROM alpine:latest

RUN apk update && apk add mariadb mariadb-client && \
    mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

EXPOSE 3306

CMD ["mysqld"]

