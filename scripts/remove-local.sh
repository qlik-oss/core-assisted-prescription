#!/bin/bash
# Removes the system from local Docker Engine using docker-compose.

set -e

cd "$(dirname "$0")"
cd ..

docker-compose down -v
