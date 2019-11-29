container_name := docker-explainshell
docker_repository_url := index.docker.io
docker_org := bossjones
GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION     ?= 1.0.0

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

bash:
	docker run --rm -i -t --entrypoint "bash" $(docker_repository_url)/$(container_name):latest -l


.PHONY: build
build:
	docker build --tag $(docker_repository_url)/$(container_name):$(GIT_SHA) -f Dockerfile .; \
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):$(TAG)
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):$(TAG)

.PHONY: build-force
build-force:
	docker build --rm --force-rm --pull --no-cache -t $(docker_repository_url)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):$(TAG)
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):$(TAG)

.PHONY: tag
tag:
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(container_name):$(TAG)
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):latest
	docker tag $(docker_repository_url)/$(container_name):$(GIT_SHA) $(docker_repository_url)/$(docker_org)/$(container_name):$(TAG)

.PHONY: build-push
build-push: build tag
	docker push $(docker_repository_url)/$(container_name):latest
	docker push $(docker_repository_url)/$(container_name):$(GIT_SHA)
	docker push $(docker_repository_url)/$(container_name):$(TAG)
	docker push $(docker_repository_url)/$(docker_org)/$(container_name):latest
	docker push $(docker_repository_url)/$(docker_org)/$(container_name):$(TAG)

.PHONY: push
push:
	docker push $(docker_repository_url)/$(docker_org)/$(container_name):latest
	docker push $(docker_repository_url)/$(docker_org)/$(container_name):$(TAG)


.PHONY: push-force
push-force: build-force push

.PHONY: release
release: push
	git tag $(VERSION)
	git push upstream --tags

.PHONY: run
run:
	docker run --rm --name boss-bash-explainshell -p 5000:5000 -p 27017:27017 $(docker_repository_url)/$(docker_org)/$(container_name):latest

