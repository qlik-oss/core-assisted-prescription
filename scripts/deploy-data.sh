#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd ..

USERNAME=$(id -u -n)
WORKERS=$(docker-machine ls | grep -c "worker")

echo "========================================================================"
echo "  Preparing workers with data"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  MACHINE=$USERNAME-docker-worker$i

  # Only deploy data if it does not already exists on host
  docker-machine ssh $MACHINE "ls /home/docker/data" &> /dev/null
  if [ $? -eq 1 ]; then
    echo "-> deploying data to $MACHINE"
    docker-machine scp -r ./data $MACHINE:/home/docker/
  fi
done
