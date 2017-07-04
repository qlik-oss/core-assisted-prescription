#!/bin/bash
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

echo
    for f in /initgrafana.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done

jobs

fg %1
