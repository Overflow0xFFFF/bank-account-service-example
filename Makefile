#/////////////////////////////////////////////////////////////////////////////#
#
# Copyright (c) 2022, Joshua Ford
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#/////////////////////////////////////////////////////////////////////////////#

# VARIABLES, CONFIG, & SETTINGS
#//////////////////////////////////////////////////////////////////////////////
#
# DATABASE_URL: Path to the database resource.
# DOCKER:       Path to the docker executable.
# FLASK_APP:    The app that Flask will start and run.
# PDM:	  	    Path to the pdm executable.
# PYTHON:		    Path to the python executable.
#
DATABASE_URL = "sqlite://app/database.db"
DOCKER       = /bin/docker
FLASK_APP    = app/app.py
PDM          = $(HOME)/.local/bin/pdm
PYTHON       = /bin/python

# Arguments and variables used with Docker.
#
# BUILD_DATE: The build date of the container in RFC 3339 format.
# GIT_REF:    The current Git commit sha1 of the repository.
#
BUILD_DATE      = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
#GIT_REF         = $(shell git rev-parse --verify HEAD)
GIT_REF         = abcdef
IMAGE           = $(REGISTRY)/$(IMAGE_NAMESPACE)/$(IMAGE_NAME)
IMAGE_NAMESPACE := overflow0xffff
IMAGE_NAME      := bankservice
IMAGE_TAG       := 0.1.0
REGISTRY        := ghcr.io
SNAPSHOT_TAG    = $(IMAGE_TAG)-SNAPSHOT-$(GIT_REF)

# Helper variable to identify all images built by our container builder.
# Used in the `clean` target to remove all build artifacts.
#
DOCKER_CACHE = $(shell $(BUILDER) images --format '{{.Repository}}:{{.Tag}}' | \
   	grep "$(IMAGE_NAMESPACE)/$(IMAGE_NAME)")

# TASKS
#//////////////////////////////////////////////////////////////////////////////

.DEFAULT_GOAL := help

.PHONY: clean
clean: ## Clean the working directory of generated directories and materials.
	rm -rf __pycache__
	rm -rf __pypackages__

.PHONY: init
init: ## Initialize project and retrieve dependencies.
	@$(PDM) sync --clean

.PHONY: run
run: ## Serve the web application on http://localhost:3000.
	@FLASK_APP=$(FLASK_APP) DATABASE_URL=$(DATABASE_URL) $(PDM) run flask run -p 3000

.PHONY: db/init
db/init: ## Initialize the database.
	docker-compose run --rm manage db init

.PHONY: db/migrate
db/migrate: ## Migrate the database schema.
	#@FLASK_APP=$(FLASK_APP) DATABASE_URL=$(DATABASE_URL) $(PDM) run flask db migrate
	docker-compose run --rm manage db migrate

.PHONY: db/upgrade
db/upgrade: ## Upgrade the database.
	#@FLASK_APP=$(FLASK_APP) DATABASE_URL=$(DATABASE_URL) $(PDM) run flask db upgrade
	docker-compose run --rm manage db upgrade

.PHONY: docker/clean
docker/clean: ## Clean up any built docker images.
	$(DOCKER) rmi $(CACHE)

.PHONY: docker/build
docker/build: ## Build the application as a Docker container.
	$(DOCKER) build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg GIT_REF=$(GIT_REF) \
		-t $(IMAGE):$(SNAPSHOT_TAG) .

.PHONY: docker/stop
docker/stop: ## Stop the application and clean up volumes.
	docker-compose down --volumes

.PHONY: docker/start
docker/start: ## Start the application with docker-compose.
	docker-compose up -d --build db
	docker-compose up -d --build web

.PHONY: help
help: ## Show this help message.
	@grep -E '^[a-zA-Z/_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "; printf "\nUsage:\n"}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo
