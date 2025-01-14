NAME = inception
COMPOSE = docker-compose.yml
INIT = init.sh
ENV_FILE = .env
DATA_DIR = /home/hwiemann/data

all: init up

init:
	@./init.sh
	@echo "$(NAME) Initialization complete"

up:	
	docker-compose up --build -d
	@echo "$(NAME) Started"

down:
	@docker-compose -p $(NAME) down
	@echo "$(NAME) Stopped"

clean: down
	@docker-compose -f $(COMPOSE) down --remove-orphans
	@docker rm -f nginx wordpress mariadb 2>/dev/null || true
	docker system prune --force
	@echo "Containers Removed"

purge: clean
	@docker volume rm $$(docker volume ls -q -f name=$(NAME)) 2>/dev/null || true
	@echo "Volumes Removed"
	@sudo rm -rf $(DATA_DIR)
	@echo "Data directory $(DATA_DIR) removed"

fclean: clean
	@docker image rm -f $(NAME)-nginx $(NAME)-wordpress $(NAME)-mariadb 2>/dev/null || true
	@echo "Images Removed"

re: fclean all
