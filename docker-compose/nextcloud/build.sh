#!/bin/bash

DIRECTORY=$(dirname "$0")
cd "$DIRECTORY"

. /etc/default/nextcloud

docker pull nextcloud:${NEXTCLOUD_VERSION}

docker compose --env-file /etc/default/nextcloud build

