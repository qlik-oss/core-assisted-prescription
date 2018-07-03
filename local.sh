#!/bin/bash

set -e

# move into project root:
cd "$(dirname "$0")"

command=$1

function deploy() {
  if [[ -z "$LICENSES_SERIAL_NBR" || -z "$LICENSES_CONTROL_NBR" ]]; then
    echo "Error: License environment variables LICENSES_SERIAL_NBR and/or LICENSES_CONTROL_NBR not properly set"
    exit 1
  fi
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
