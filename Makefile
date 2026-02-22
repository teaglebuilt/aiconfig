CONTAINER_NAME := aiconfig-container
IMAGE_NAME := aiconfig-claude

install:
	./scripts/install.sh

container-build:
	docker build -t $(IMAGE_NAME) .

container-up: container-build
	docker run -d --rm \
		--name $(CONTAINER_NAME) \
		-v "$$PWD":/workspace/aiconfig \
		-w /workspace/aiconfig \
		$(IMAGE_NAME)

container-shell:
	docker exec -it $(CONTAINER_NAME) zsh

container-down:
	docker stop $(CONTAINER_NAME)