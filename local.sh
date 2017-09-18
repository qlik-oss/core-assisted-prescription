#!/bin/bash

set -e

# move into project root:
cd "$(dirname "$0")"

command=$1

function deploy() {
  docker-compose up -d dummy-data
  docker cp ./data/csv/. dummy-data:/data
  docker cp ./data/doc/. dummy-data:/doc
  docker cp ./secrets/. dummy-data:/secrets
  JWT_SECRET=$(cat ./secrets/JWT_SECRET) docker-compose up -d
  echo "CUSTOM ANALYTICS deployed locally at https://localhost/"
}

function remove() {
  docker-compose down -v
  echo "CUSTOM ANALYTICS removed locally"
}

if [ "$command" == "deploy" ]; then deploy
elif [ "$command" == "remove" ]; then remove
else echo "Invalid option: $command - please use one of: deploy, remove"; fi
