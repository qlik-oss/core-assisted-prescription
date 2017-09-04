#!/bin/bash
# Deploys the system on local Docker Engine using docker-compose.

set -e

cd "$(dirname "$0")"
cd ..

# Set Env. variable used as JWT secret. 
JWT_SECRET_FILE="./secrets/JWT_SECRET"
export JWT_SECRET=$(cat "$JWT_SECRET_FILE")

docker-compose up -d dummy-data

docker cp ./data/csv/. dummy-data:/data
docker cp ./data/doc/. dummy-data:/doc
docker cp ./secrets/. dummy-data:/secrets

docker-compose up -d
echo
echo
echo "CUSTOM ANALYTICS can be reached at https://localhost/"
