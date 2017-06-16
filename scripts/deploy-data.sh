#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd ..

USERNAME=$(id -u -n)
WORKERS=$(docker-machine ls | grep -c "worker")

while [[ $# -gt 0 ]]
do
  arg="$1"

  case $arg in
    -o)
    OVERWRITE="1"
    ;;
  esac
  shift # past arg
done

echo "========================================================================"
echo "  Preparing workers with data"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  MACHINE=$USERNAME-docker-worker$i

  # Only deploy data if it does not already exists on host or if override switch was specified
  docker-machine ssh $MACHINE "ls /home/docker/data" &> /dev/null
  if [[ $? -eq 1 ||  $OVERWRITE -eq "1" ]]; then
    echo "-> deploying data to $MACHINE"
    docker-machine scp -r ./data $MACHINE:/home/docker/
  else
    echo "Not deploying data to $MACHINE, since it already exists"
  fi
done
