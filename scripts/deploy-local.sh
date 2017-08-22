#!/bin/bash
# Deploys the system on local Docker Engine using docker-compose.

set -e

cd "$(dirname "$0")"
cd ..

docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml config > docker-compose.local.yml
docker-compose -f ./docker-compose.local.yml up -d dummy-data

docker cp ./data/csv/. dummy-data:/data
docker cp ./data/doc/. dummy-data:/doc
docker cp ./secrets/. dummy-data:/secrets

docker-compose up -d
echo
echo
echo "CUSTOM ANALYTICS can be reached at https://localhost/"
