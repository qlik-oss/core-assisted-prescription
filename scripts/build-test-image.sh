#!/bin/bash
# Builds the Docker image for e2e and performance tests.
# Prints image tag to stdout.

set -e

IMAGE_NAME=test/qliktive-custom-analytics-test

cd "$(dirname "$0")"
cd ../test
docker build -t $IMAGE_NAME ../test/ &> /dev/null
echo "$IMAGE_NAME:latest"
