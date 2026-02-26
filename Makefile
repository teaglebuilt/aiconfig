SERVICE_NAME := claude-code

install:
	./scripts/install.sh

container-build:
	docker compose build

container-up:
	docker compose up -d

container-shell:
	docker compose exec $(SERVICE_NAME) zsh

container-down:
	docker compose down