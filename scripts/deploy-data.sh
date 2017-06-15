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
  DRIVER=$(docker-machine inspect --format '{{.DriverName}}' $MACHINE)

  echo "-> deploying data to $MACHINE"
  if [ $DRIVER == "amazonec2" ]; then
    # Creating '/home/docker' on aws nodes
    docker-machine ssh $MACHINE "sudo install -g ubuntu -o ubuntu -d /home/docker"
  fi
  docker-machine scp -r ./data $MACHINE:/home/docker
done
