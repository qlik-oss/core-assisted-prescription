#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ../test

echo "### Find out IP address of gateway"
CONTAINER_ID=$(docker ps -aqf "name=openresty")
GATEWAY_IP_ADDR=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' "$CONTAINER_ID")
echo "GATEWAY_IP_ADDR=$GATEWAY_IP_ADDR"

echo "### Execute tests"
docker run --rm -e "GATEWAY_IP_ADDR=$GATEWAY_IP_ADDR" test/qliktive-custom-analytics-test test:e2e:swarm
