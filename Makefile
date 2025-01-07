NAME = inception
HOST_URL = hwiemann.42.fr
COMPOSE = docker-compose.yml

update_hosts:
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > /dev/null 2>&1 && echo "Host $(HOST_URL) Added"
	@docker-compose -p $(NAME) -f $(COMPOSE) up --build -d || (echo "Failed" && exit 1)
	@echo "$(NAME) Executed"

all: up

up:	
	docker-compose up --build -d

down:
	@docker-compose -p $(NAME) down
	@echo "$(NAME) Stopped"

remove_host:
	@sudo sed -i '/$(HOST_URL)/d' /etc/hosts


clean: down
	@docker-compose -f $(COMPOSE) down --remove-orphans
	@docker rm -f nginx wordpress mariadb 2>/dev/null || true
	docker system prune --force
	@echo "Containers Removed"

purge: clean
	docker volume rm -f $(docker volume ls -q)
	@echo "Volumes Removed"

fclean: clean
	@docker image rm -f $(NAME)-nginx $(NAME)-wordpress $(NAME)-mariadb 2>/dev/null || true
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > /dev/null 2>&1 && echo "Host $(HOST_URL) Removed"
	@echo "Images Removed"

re: fclean all
