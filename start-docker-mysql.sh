#!/usr/bin/env sh
set -e

docker-compose -f docker-compose.yml --env-file env-mysql down
docker-compose -f docker-compose.yml --env-file env-mysql up -d