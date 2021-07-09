.PHONY: bundle validate server

include .env

CONTAINER_ENGINE ?= $(shell which podman >/dev/null 2>&1 && echo podman || echo docker)
OUTPUT_DIR ?= $(shell pwd)
OUTPUT_DIR := $(shell realpath $(OUTPUT_DIR))
BUNDLE_FILENAME ?= data.json
PWD := $(shell pwd)
GIT_COMMIT := $(shell git rev-parse HEAD)
GIT_COMMIT_TIMESTAMP := $(shell git log -1 --format=%ct $(GIT_COMMIT))

bundle:
	mkdir -p $(OUTPUT_DIR)
	# cp --parents docs/**/*.md resources
	@$(CONTAINER_ENGINE) run --rm \
		-v $(PWD)/schemas:/schemas:z \
		-v $(PWD)/graphql-schemas:/graphql:z \
		-v $(PWD)/data:/data:z \
		-v $(PWD)/resources:/resources:z \
		$(VALIDATOR_IMAGE):$(VALIDATOR_IMAGE_TAG) \
		qontract-bundler /schemas /graphql/schema.yml /data /resources $(GIT_COMMIT) $(GIT_COMMIT_TIMESTAMP) > $(OUTPUT_DIR)/$(BUNDLE_FILENAME)

validate:
	@$(CONTAINER_ENGINE) run --rm \
		-v $(OUTPUT_DIR):/bundle:z \
		$(VALIDATOR_IMAGE):$(VALIDATOR_IMAGE_TAG) \
		qontract-validator --only-errors /bundle/$(BUNDLE_FILENAME)

toc:
	./hack/toc.py

server: bundle validate
	@$(CONTAINER_ENGINE) run -it --rm \
		-v $(OUTPUT_DIR):/bundle:z \
		-p 4000:4000 \
		-e LOAD_METHOD=fs \
		-e DATAFILES_FILE=/bundle/$(BUNDLE_FILENAME) \
		$(QONTRACT_SERVER_IMAGE):$(QONTRACT_SERVER_IMAGE_TAG)

qr-promote:
	@./hack/update-qr-tag.sh
