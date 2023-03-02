.PHONY: help

CONTAINER_PHP=php-server
CONTAINER_NODE=node-server
CONTAINER_DATABASE=database-server
CONTAINER_REDIS=redis-server
CONTAINER_QUEUE=queue-server

VOLUME_DATABASE=laravel-microservices_db-data



help: ## Print help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ps: ## Show All containers
	@docker compose ps

build: ## Build All Conatiners
	@docker build --no-cache .

start: ## Start All containers
	@docker compose up --force-recreate -d

fresh: stop destroy-auto build start ##  stop, destroy and recreate all containers.

stop: ## Only stop all containers, but not removed
	@docker compose stop

restart: stop start ## Restart all containers

destroy:  stop ## Stop and remove all containers
	@docker rm -vf ${CONTAINER_PHP}
	@docker rm -vf ${CONTAINER_DATABASE}
	@docker rm -vf ${CONTAINER_NODE}
	@docker rm -vf ${CONTAINER_REDIS}
	@docker rm -vf ${CONTAINER_QUEUE}
	
	@if [ "$(shell docker volume ls --filter name=${VOLUME_DATABASE} --format {{.Name}})" ]; then\
		docker volume rm ${VOLUME_DATABASE};\
	fi

destroy-auto:  stop ## Stop and remove all containers
	@docker compose down
	
	@if [ "$(shell docker volume ls --filter name=${VOLUME_DATABASE} --format {{.Name}})" ]; then\
		docker volume rm ${VOLUME_DATABASE};\
	fi

cache: ## Cache project
	docker exec ${CONTAINER_PHP} php artisan view:cache
	docker exec ${CONTAINER_PHP} php artisan config:cache
	docker exec ${CONTAINER_PHP} php artisan event:cache
	docker exec ${CONTAINER_PHP} php artisan route:cache

cache-clear: ## Clear Cache
	docker exec ${CONTAINER_PHP} php artisan cache:clear
	docker exec ${CONTAINER_PHP} php artisan view:clear
	docker exec ${CONTAINER_PHP} php artisan config:clear
	docker exec ${CONTAINER_PHP} php artisan event:clear
	docker exec ${CONTAINER_PHP} php artisan route:clear

migrate: ## Run migration files
	docker exec ${CONTAINER_PHP} php artisan migrate

migrat-fresh: ## Clear Database and run all migrations
	docker exec ${CONTAINER_NODE} php artisan migrate:fresh

npm-install: ## Install frontend assets
	docker exec ${CONTAINER_NODE} npm install

npm-dev: ## Compile front assets for dev
	docker exec ${CONTAINER_NODE} npm run dev

npm-prod: ## Compile front assets for production
	docker exec ${CONTAINER_NODE} npm run production

logs: ## Print all docker logs
	docker compose logs -f

logs-php: ## Print all logs for PHP Container
	docker logs ${CONTAINER_PHP}

logs-node: ## Print all logs for NODE Container
	docker logs ${CONTAINER_NODE}

logs-redis: ## Print all logs for REDIS Container
	docker logs ${CONTAINER_REDIS}

logs-queue: ## Print all logs for QUEUE Container
	docker logs ${CONTAINER_QUEUE}

logs-db: ## Print all logs for DATABASE Container
	docker logs ${CONTAINER_DATABASE}


ssh-php: ## SSH Inside PHP Container
	docker exec -it ${CONTAINER_PHP} sh

ssh-node: ## SSH Inside NODE Container
	docker exec -it ${CONTAINER_NODE} sh

ssh-redis: ## SSH Inside REDIS Container
	docker exec -it ${CONTAINER_REDIS} sh

#ssh-queue: ## SSH Inside QUEUE Container
#	#docker exec -it ${CONTAINER_QUEUE} sh
	
ssh-db: ## SSH Inside DATABASE Container
	docker exec -it ${CONTAINER_DATABASE} sh