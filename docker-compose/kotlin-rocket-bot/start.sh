#!/bin/bash

export DOCKER_VERSION="$(docker -v)"
export LINUX_VERSION="$(uname -a)"

docker compose -f /opt/admin-tools/docker-compose/kotlin-rocket-bot/docker-compose.yml up -d --remove-orphans

