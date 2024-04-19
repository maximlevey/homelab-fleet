compose_v2_not_supported = $(shell command docker compose 2> /dev/null)
ifeq (,$(compose_v2_not_supported))
  DOCKER_COMPOSE_COMMAND = docker-compose
else
  DOCKER_COMPOSE_COMMAND = docker compose
endif

.PHONY: setup start stop restart reset

setup:
	scripts/setup_tunnel.sh

start:
	scripts/start_services.sh

stop:
	$(DOCKER_COMPOSE_COMMAND) down

restart:
	$(DOCKER_COMPOSE_COMMAND) restart

reset:
	$(DOCKER_COMPOSE_COMMAND) down -v
	@make start

