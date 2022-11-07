PROJECT         := ansible
GIT_SHA         ?= $(shell git log --format=%h -1 .)
GIT_BRANCH      ?= $(shell git rev-parse --abbrev-ref HEAD)
ECR_REGISTRY    := 242369466814.dkr.ecr.us-east-2.amazonaws.com
ECR_IMAGE       := ${ECR_REGISTRY}/${PROJECT}:${GIT_SHA}
DOCKER_PLATFORM ?= linux/$(shell uname -m)

.PHONY: default
default: help

.PHONY: help
help: ## Shows the help
	@echo 'Usage: make <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	        awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ''
	@echo ''

.PHONY: login
login : ## login to docker
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${ECR_REGISTRY}

.PHONY: docker-build
docker-build: ## build the image
	docker build --platform=${DOCKER_PLATFORM} -t ${ECR_IMAGE} .

.PHONY: test
test: ## run goss tests
	docker run --rm ${ECR_IMAGE} goss validate -f documentation

.PHONY: tag-latest
tag-latest: ## docker tag the image
	docker tag ${ECR_IMAGE} ${ECR_REGISTRY}/${PROJECT}:latest

.PHONY: shell
shell: ## run a shell in the container
	docker run -it --rm ${ECR_IMAGE} bash

.PHONY: build
build: DOCKER_PLATFORM = "linux/amd64"
build: login docker-build tag-latest test ## build, tag, test, and push the docker image
	docker push ${ECR_IMAGE}
	docker push ${ECR_REGISTRY}/${PROJECT}:latest

