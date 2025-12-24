IMAGE_NAME = nfs-server
TAG = $(shell git rev-parse --short HEAD)

# Default action
default: help

.PHONY: help
help: # Show this help
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

# Docker
.PHONY: docker-build
docker-build: # Build Docker image
	@docker build -t $(IMAGE_NAME):latest .
docker-run:	 # Run Docker container
	@docker run --privileged -v ./share:/exports -p 2049:2049 -p 111:111 $(IMAGE_NAME):latest

.PHONY: docker-test
docker-test: # Test Dockerfile with Checkov
	@checkov --quiet --compact --file Dockerfile

# Helm
.PHONY: helm-build
helm-build: # Build Helm chart
	@helm4 package charts/nfs-server -d dist/
	@echo "Helm chart built and saved to dist/ directory."

.PHONY: helm-test
helm-test: # Test Helm chart
	@helm4 lint charts/nfs-server
# 	@helm template nfs-server charts/nfs-server --debug
	@echo "Helm chart test completed successfully."
.PHONY: helm-docs
helm-docs: # Generate Helm chart documentation
	@helm-docs charts/nfs-server
	@echo "Helm chart documentation generated."

# Tests
.PHONY: test
test: helm-test docker-test # Run all tests
	@echo "All tests completed successfully."

.PHONY: kind-load
kind-load: # Load Docker image into Kind cluster
	@kind load docker-image $(IMAGE_NAME):latest
	@echo "Docker image $(IMAGE_NAME):latest loaded into Kind cluster."
