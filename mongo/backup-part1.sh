#!/bin/bash

rm -rf /mnt/backup/mongodb/dump/* || exit 1
docker exec mongo mongodump --out=/backup || exit 1

