#!/bin/bash
set -e

GATEWAY_IP_ADDR=
AVG_USERS=500
MAX_USERS=10000

while getopts ":m:a:g:" opt; do
  case $opt in
    g)
      GATEWAY_IP_ADDR=$OPTARG
      ;;
    m)
      MAX_USERS=$OPTARG
      ;;
    a)
      AVG_USERS=$OPTARG
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

if [[ -z $GATEWAY_IP_ADDR ]]; then
    CONTAINER_ID=$(docker ps -aqf "name=openresty")
    GATEWAY_IP_ADDR=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' "$CONTAINER_ID")
fi

echo "================================================================================"
echo " Running qliktive-custom-analytics performance benchmarking"
echo " Gateway: $GATEWAY_IP_ADDR"
echo " Average number of users: $AVG_USERS"
echo " Max number of users: $MAX_USERS"
echo "================================================================================"

docker run --rm -e "GATEWAY_IP_ADDR=$GATEWAY_IP_ADDR" test/qliktive-custom-analytics-test perf-bench -- -a $AVG_USERS -m $MAX_USERS
