.PHONY: up-d down ps check-mount show-pg-dir-permits help
docker-config: ## Show the docker compose configuration
	docker compose \
	--env-file deployment/.env \
	-f deployment/compose.yaml \
	config
docker-build: ## Build the docker images
	@if [ "$(opt)" = "" ]; then \
		echo "Building all images..."; \
		docker compose \
		--env-file deployment/.env \
		-f deployment/compose.yaml \
		build; \
	else \
		docker compose \
		--env-file deployment/.env \
		-f deployment/compose.yaml \
		build $(opt); \
	fi
	
up-d: ## Start the application in detached mode
	docker compose \
	--env-file deployment/.env \
	-f deployment/compose.yaml \
	up -d

down: ## Stop the application and remove volumes
	@if [ "$(opt)" = "v" ]; then \
		echo "Removing volumes..."; \
		docker compose \
		-f deployment/compose.yaml \
		down -v; \
	else \
		docker compose \
		-f deployment/compose.yaml \
		down; \
	fi

ps: ### Show the status of the application
	docker compose \
	--env-file deployment/.env \
	-f deployment/compose.yaml \
	ps

check-mount: ## Check the mount of the postgres data directory (don manually if error)
	docker inspect \
	"$(docker compose --env-file deployment/.env -f deployment/compose.yaml ps -q postgres)" \
	--format '{{json .Mounts}}'

show-pg-dir-permits: ## Show the permission of the postgres data directory
	docker run --rm postgres:17-alpine id postgres

help: ## Show available commands
	@echo ""
	@echo "  $(BOLD)Make — dev commands$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(CYAN)%-20s$(RESET) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@echo ""
