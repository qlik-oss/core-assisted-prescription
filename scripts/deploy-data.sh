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
    -u)
    USERNAME="$2"
    shift # past arg
    ;;
  esac
  shift # past arg
done

echo "========================================================================"
echo "  Preparing workers with data"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  MACHINE=$USERNAME-docker-worker$i
  DRIVER=$(docker-machine inspect --format '{{.DriverName}}' $MACHINE)

  # Only deploy data if it does not already exists on host or if override switch was specified
  docker-machine ssh $MACHINE "ls /home/docker/data" &> /dev/null
  if [[ $? -eq 1 ||  $OVERWRITE -eq "1" ]]; then
    echo "-> deploying data to $MACHINE"

    if [ $DRIVER == "amazonec2" ]; then
      # Creating '/home/docker' on aws nodes
      docker-machine ssh $MACHINE "sudo install -g ubuntu -o ubuntu -d /home/docker"
    fi

    docker-machine scp -r ./data $MACHINE:/home/docker/
  else
    echo "Not deploying data to $MACHINE, since it already exists"
  fi
done
