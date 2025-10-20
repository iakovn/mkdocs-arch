SHELL := /bin/bash

# Helper: detect if inside a Docker container
IN_DOCKER := $(shell [ -f /.dockerenv ] && echo yes || ([ "$$INSIDE_DOCKER" = "1" ] && echo yes || echo no))

.PHONY: help

## Print this help
help:
	@awk '/^## / \
        { if (c) {print c}; c=substr($$0, 4); next } \
         c && /(^[[:alpha:]][[:alnum:]_-]+:)/ \
        {printf "\033[36m%-30s\033[0m %s\n", $$1, c; c=0} \
         END { print c }' $(MAKEFILE_LIST)


# {print $$1, "\t", c; c=0}
# _run <command> <args...>
# If inside container: run command directly in shell.
# Otherwise: run using 'docker run --rm -v .:/workspace mkdocs <command> <args>'
define _run
echo $1 $2 $3; \
if [ "$(IN_DOCKER)" = "yes" ]; then \
  exec $1 $2 $3 $4 $5; \
else \
  docker compose -f .devcontainer/docker-compose.yml \
    run --rm -v $$(pwd):/workspace -w /workspace mkdocs $1 $2 $3 $4 $5; \
fi
endef

.PHONY: devenv build serve

## Build the mkdocs Docker image using .devcontainer/mkdocs.dockerfile (skipped inside container)
devenv:
	@echo "==> Building mkdocs image (using .devcontainer/mkdocs.dockerfile)"
	@if [ "$(IN_DOCKER)" = "yes" ]; then \
	  echo "Inside container: skipping image build"; \
	else \
	  docker compose -f .devcontainer/docker-compose.yml build; \
	fi

## Run 'mkdocs build' (inside container or via docker run)
build: devenv
	@echo "==> Running: mkdocs build"
	@bash -c '$(call _run,mkdocs,build)'

## Run 'mkdocs serve' (inside container or via docker run)
serve: devenv
	@echo "==> Running: mkdocs serve"
	@bash -c '$(call _run,mkdocs,serve,--dev-addr,0.0.0.0:8000,--watch-theme)'

## Run 'mkdocs gh-deploy' (only from local devenv)
deploy: devenv
	@echo "==> Running: mkdocs gh-deploy"
	@bash -c '$(call _run,mkdocs,gh-deploy,-v)'

package-lock.json: package.json
	@echo "==> Locking JS dependencies (npm ci && npm install --package-lock-only)"
	@bash -c 'npm ci && npm install --package-lock-only'

## Generate/update package-lock.json using npm (runs inside container or via docker compose)
lock-deps: package-lock.json
