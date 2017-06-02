#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
USERNAME=$(id -u -n)

print_usage () {
  echo
  echo "Usage:"
  echo "  scale-workers.sh [<total number of nodes>] | [up|down <number of nodes>]"
  echo "  [<total number of nodes>] - Scale swarm to <total number of nodes> nodes"
  echo "  [up|down <number of nodes>] - Scale swarm up or down with <number of nodes> nodes"
  echo ""
  echo "  Choose to either scale swarm to a fixed number of nodes, or the number of nodes to scale up/down."
  echo "  The swarm should have atleast one worker node."
}

while [[ $# -gt 0 ]]
do
  arg="$1"

  case $arg in
    up)
    ADD_WORKERS="$2"
    shift # past arg
    ;;
    down)
    REMOVE_WORKERS="$2"
    shift # past arg
    ;;
    [0-9]) # numeric
    TOTAL_WORKERS="$1"
    shift # past arg
    ;;
    *)
    print_usage
    exit 1
    ;;
  esac
  shift # past arg
done

echo "========================================================================"
echo "  Find current deployment used"
echo "========================================================================"

EXISTING_MACHINES=$(docker-machine ls)

if [[ $EXISTING_MACHINES == *"vmwarevsphere"* ]]; then
  DRIVER=vmwarevsphere
  SWITCH=
elif [[ $EXISTING_MACHINES == *"hyperv"* ]]; then
  DRIVER=hyperv
  # Get virtual switch used for HyperV in Windows
  VIRTUAL=$(docker-machine inspect $USERNAME-docker-manager1 | sed -n 's/.*"VSwitch": "\(.*\)",/\1/p')
  SWITCH="--hyperv-memory 2048 --hyperv-virtual-switch $VIRTUAL"
elif [[ $EXISTING_MACHINES == *"virtualbox"* ]]; then
  DRIVER=virtualbox
  SWITCH="--virtualbox-memory 2048"
else
  echo "No existing deployment found or unknown driver is used"
  print_usage
  exit 1
fi

echo "Current deployment is using $DRIVER driver and switch $SWITCH"

echo "========================================================================"
echo "  Determine total number of worker node(s)"
echo "========================================================================"

EXISTING_WORKERS=$(echo "$EXISTING_MACHINES" | grep -c "$USERNAME-docker-worker")
echo "Current swarm has $EXISTING_WORKERS worker(s)"

if [ $ADD_WORKERS ]; then
  TOTAL_WORKERS=$(($EXISTING_WORKERS+$ADD_WORKERS))
elif [ $REMOVE_WORKERS ]; then
  TOTAL_WORKERS=$(($EXISTING_WORKERS-$REMOVE_WORKERS))
fi


if [[ $TOTAL_WORKERS -lt 1 ]]; then
  echo "Trying to scale worker nodes to less than one worker. Swarm should have atleast one worker node"
  print_usage
  exit 1
# Scaling up
elif [[ $TOTAL_WORKERS -gt $EXISTING_WORKERS ]]; then
  echo "========================================================================"
  echo "  Creating worker node(s)"
  echo "========================================================================"
  echo "Scaling up swarm to $TOTAL_WORKERS workers"

  for i in $(seq $(($EXISTING_WORKERS+1)) 1 $TOTAL_WORKERS); do
    echo "-> Creating $USERNAME-docker-worker$i machine ..."
    docker-machine create -d $DRIVER $SWITCH --engine-opt experimental=true --engine-label env=test $USERNAME-docker-worker$i &
  done

  wait # wait for new nodes to be up and running

  echo "========================================================================"
  echo "  Make new worker nodes part of the swarm"
  echo "========================================================================"
  eval $(docker-machine env $USERNAME-docker-manager1)
  WORKERTOKEN=$(docker swarm join-token -q worker)
  echo "Using worker token $WORKERTOKEN for joining the swarm"

  for i in $(seq $(($EXISTING_WORKERS+1)) 1 $TOTAL_WORKERS); do
    echo "-> $USERNAME-docker-worker$i joining swarm as worker ..."
    docker-machine ssh $USERNAME-docker-worker$i docker swarm join --token $WORKERTOKEN $(docker-machine ip $USERNAME-docker-manager1):2377
  done

  # deploy data to all worker nodes so that it can be accessed locally
  ./deploy-data.sh

# Scaling down
elif [[ $TOTAL_WORKERS -lt $EXISTING_WORKERS ]]; then
  echo "========================================================================"
  echo "  Removing worker node(s)"
  echo "========================================================================"
  echo "Scaling down swarm to $TOTAL_WORKERS worker(s)"

  # Remove worker nodes in reverse order
  for i in $(seq $EXISTING_WORKERS -1 $(($TOTAL_WORKERS+1))); do
    echo "-> Removing $USERNAME-docker-worker$i machine ..."
    docker-machine ssh $USERNAME-docker-worker$i docker swarm leave # remove worker node from swarm
    docker-machine ssh $USERNAME-docker-manager1 docker node rm -f $USERNAME-docker-worker$i # remove worker node from manager node list
    docker-machine rm -y $USERNAME-docker-worker$i # remove docker-machine
  done
fi

echo "========================================================================"
echo "  STATUS"
echo "========================================================================"
echo "-> list nodes"
docker-machine ls
