#!/bin/bash

set -e

# move into project root:
cd "$(dirname "$0")"

command=$1
green="\033[0;32m"
nocolor="\033[0m"

function deploy() {
  LICENSE_COMPOSE_FLAG="-f docker-compose.licensing.yml"
  if [[ -z "$LICENSES_SERIAL_NBR" || -z "$LICENSES_CONTROL_NBR" ]]; then
    echo -e "${green}INFO${nocolor}: Running Qlik Associative Engine without license. The number of simultaneous sessions will be restricted."
    LICENSE_COMPOSE_FLAG=""
  fi
  docker-compose up -d dummy-data
  docker cp ./data/csv/. dummy-data:/data
  docker cp ./data/doc/. dummy-data:/doc
  docker cp ./secrets/. dummy-data:/secrets
  JWT_SECRET=$(cat ./secrets/JWT_SECRET) docker-compose -f docker-compose.yml -f docker-compose.override.yml $LICENSE_COMPOSE_FLAG up -d
  echo "CUSTOM ANALYTICS deployed locally at https://localhost/"
}

function remove() {
  docker-compose down -v
  echo "CUSTOM ANALYTICS removed locally"
}

if [ "$command" == "deploy" ]; then deploy
elif [ "$command" == "remove" ]; then remove
else echo "Invalid option: $command - please use one of: deploy, remove"; fi
