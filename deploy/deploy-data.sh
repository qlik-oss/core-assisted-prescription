#!/bin/bash
USERNAME=$(id -u -n)
WORKERS=$(docker-machine ls | grep -c "worker")

echo "========================================================================"
echo "Preparing workers with data"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  MACHINE=$USERNAME-docker-worker$i
  echo "-> deploying data to $MACHINE"
  docker-machine scp -r ../data $MACHINE:/home/docker/
done
