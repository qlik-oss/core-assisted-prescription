#!/bin/bash

set -e

echo "========================================================================"
echo "Removing Docker Swarm cluster"
echo "========================================================================"
docker-machine rm $(docker-machine ls --filter label=env=test -q)
