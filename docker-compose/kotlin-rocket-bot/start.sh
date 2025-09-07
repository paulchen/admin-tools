#!/bin/bash

export DOCKER_VERSION="$(docker -v)"
export LINUX_VERSION="$(uname -a)"

MONGO_IMAGE="$(docker inspect --format='{{.Config.Image}}' mongo)"
export MONGO_IMAGE_DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' $MONGO_IMAGE | sed -e 's/^.*://')"

docker compose -f /opt/admin-tools/docker-compose/kotlin-rocket-bot/docker-compose.yml up -d --remove-orphans

