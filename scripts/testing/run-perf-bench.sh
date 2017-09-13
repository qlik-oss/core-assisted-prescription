#!/bin/bash
set -e

cd "$(dirname "$0")"

GATEWAY_IP_ADDR=
DURATION=60

while getopts ":m:d:g:" opt; do
  case $opt in
    g)
      GATEWAY_IP_ADDR=$OPTARG
      ;;
    d)
      DURATION=$OPTARG
      ;;
    m)
      MAX_USERS=$OPTARG
      ;;
    \?)
      echo "Error - Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Error - Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo "========================================================================"
echo " Building test image"
echo "========================================================================"
./build-test-image.sh

if [[ -z $GATEWAY_IP_ADDR ]]; then
    CONTAINER_ID=$(docker ps -aqf "name=openresty")
    GATEWAY_IP_ADDR=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' "$CONTAINER_ID")
fi

echo
echo "========================================================================"
echo " Running test image (perf-bench)"
echo "========================================================================"
docker run --rm test/qliktive-custom-analytics-test perf-bench -- -g $GATEWAY_IP_ADDR -m $MAX_USERS -d $DURATION
