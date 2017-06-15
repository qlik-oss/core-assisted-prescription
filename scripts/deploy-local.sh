#!/bin/bash
# Deploys the system on local Docker Engine using docker-compose.

set -e

cd "$(dirname "$0")"
cd ..

docker-compose up -d dummy-data

docker cp ./data/csv/. dummy-data:/data
docker cp ./data/doc/. dummy-data:/doc
docker cp ./secrets/. dummy-data:/secrets

docker-compose up -d
