SHELL := /bin/bash

# Helper: detect if inside a Docker container
IN_DOCKER := $(shell [ -f /.dockerenv ] && echo yes || ([ "$$INSIDE_DOCKER" = "1" ] && echo yes || echo no))

# _run <command> <args...>
# If inside container: run command directly in shell.
# Otherwise: run using 'docker run --rm -v .:/workspace mkdocs <command> <args>'
define _run
echo $1 $2 $3; \
if [ "$(IN_DOCKER)" = "yes" ]; then \
  exec $1 $2 $3 $4; \
else \
  docker compose -f .devcontainer/docker-compose.yml \
    run --rm -v $$(pwd):/workspace -w /workspace mkdocs $1 $2 $3 $4; \
fi
endef

.PHONY: devenv build serve help

devenv:
	@echo "==> Building mkdocs image (using .devcontainer/mkdocs.dockerfile)"
	@if [ "$(IN_DOCKER)" = "yes" ]; then \
	  echo "Inside container: skipping image build"; \
	else \
	  docker compose -f .devcontainer/docker-compose.yml build; \
	fi

build: devenv
	@echo "==> Running: mkdocs build"
	@bash -c '$(call _run,mkdocs,build)'

serve: devenv
	@echo "==> Running: mkdocs serve"
	@bash -c '$(call _run,mkdocs,serve,--dev-addr,0.0.0.0:8000)'

help: 
	@printf "Available targets:\n"
	@printf "  devenv  - Build the mkdocs Docker image using .devcontainer/mkdocs.dockerfile (skipped inside container)\n"
	@printf "  build   - Run 'mkdocs build' (inside container or via docker run)\n"
	@printf "  serve   - Run 'mkdocs serve' (inside container or via docker run)\n"
	@printf "  help    - Show this help\n"
