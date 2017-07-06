#!/bin/bash
# these scripts comes (and have been slightly modified from the docker images used in this guide: https://medium.com/@basilio.vera/docker-swarm-metrics-in-prometheus-e02a6a5745a
set -o monitor

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

exec /run.sh "$@" &

for i in {90..0}; do
  if curl -sf "http://localhost:3000"; then
    break
  fi
  printf "."
  sleep 1
done

if [ "$i" = 0 ]; then
  printf "\n${RED}Grafana start timeout!${NC}\n"
  exit 1
fi
printf "${GREEN}Grafana service ready!${NC}\n"

. /datasource_prometheus
. /import_dashboards

jobs

fg %1
