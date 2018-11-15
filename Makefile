.PHONY: build validate build-app-interface build-nginx-gate run-app-interface

APP_ROOT := /validator
IMAGE_NAME_VALIDATOR := app-interface-validator:latest
IMAGE_NAME_APP_INTERFACE := quay.io/app-sre/app-interface:latest
IMAGE_NAME_NGINX_GATE := quay.io/app-sre/app-interface-nginx-gate:latest

build:
	@docker build -t $(IMAGE_NAME_VALIDATOR) -f dockerfiles/Dockerfile.validator .

validate: build
	@docker run \
		-v ${PWD}/schemas:$(APP_ROOT)/schemas:z \
		-v ${PWD}/data:$(APP_ROOT)/data:z \
		$(IMAGE_NAME_VALIDATOR) \
		--schemas-root $(APP_ROOT)/schemas \
		--data-root $(APP_ROOT)/data


build-app-interface:
	@docker build -t $(IMAGE_NAME_APP_INTERFACE) -f dockerfiles/Dockerfile.app-interface .

build-nginx-gate:
	@docker build -t $(IMAGE_NAME_NGINX_GATE) -f dockerfiles/nginx-gate/Dockerfile dockerfiles/nginx-gate/

run-app-interface: build-app-interface
	@docker run -p 4000:4000 $(IMAGE_NAME_APP_INTERFACE)
