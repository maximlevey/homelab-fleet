.DEFAULT_GOAL:=help

compose_v2_not_supported = $(shell command docker compose 2> /dev/null)
ifeq (,$(compose_v2_not_supported))
  DOCKER_COMPOSE_COMMAND = docker-compose
else
  DOCKER_COMPOSE_COMMAND = docker compose
endif

# --------------------------
.PHONY: setup keystore certs all elk monitoring build down stop restart rm logs

setup:		    ## Generate setup configuration files
	.config/setup_certs.sh

fleet:		    ## Start fleetdm and required services
	$(DOCKER_COMPOSE_COMMAND) up -d --build

prune:			## Remove Containers and Delete related Volume Data
	@make stop && make rm
	@docker volume prune -f --filter label=com.docker.compose.project=fleetdm

help:       	## Show this help.
	@echo "Make Application Docker Images and Containers using Docker-Compose files in 'docker' Dir."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)