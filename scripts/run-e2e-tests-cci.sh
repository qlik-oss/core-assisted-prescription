#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ../test

echo "### Starting dummy-data container"
docker-compose up -d dummy-data

echo "### Copying to dummy-data container"
docker cp ../data/csv/. dummy-data:/data
docker cp ../data/doc/. dummy-data:/doc
docker cp ../secrets/cert-gateway.crt dummy-data:/secrets
docker cp ../secrets/cert-gateway.key dummy-data:/secrets

echo "### Starting full stack"
docker-compose up -d

echo "### Find out IP address of gateway"
CONTAINER_ID=$(docker ps -aqf "name=openresty")
GATEWAY_IP_ADDR=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' "$CONTAINER_ID")
echo "GATEWAY_IP_ADDR=$GATEWAY_IP_ADDR"

echo "### Build Docker image for test"
docker build --build-arg TEST_HOST="$GATEWAY_IP_ADDR" -t test/test-e2e .

echo "### Execute tests"
docker run --rm test/test-e2e
