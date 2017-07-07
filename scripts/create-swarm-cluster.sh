#!/bin/bash

set -e
cd "$(dirname "$0")" # change execution directory due to use of relative paths

# Set the amount of managers and worker nodes
MANAGERS=1
WORKERS=2
USERNAME=$(id -u -n)

print_usage () {
  echo
  echo "Usage:"
  echo "  create-swarm-cluster.sh -d <deployment> [-v <switch>] [-u <username>]"
  echo "  -d <deployment> - Type of deployment. Currently supported deployments are; local / vsphere / amazonec2"
  echo "  -v <switch>     - Windows only. Use <switch> as HyperV virtual switch."
  echo "                    Overrides the HYPERV_VIRTUAL_SWITCH environment variable."
  echo "  -u <username>   - Possibility to override the username in machinename."
  echo
}

while [[ $# -gt 1 ]]
do
  arg="$1"

  case $arg in
    -d)
    DEPLOYMENT="$2"
    shift # past arg
    ;;
    -v)
    SWITCH="$2"
    shift # past arg
    ;;
    -u)
    USERNAME="$2"
    shift # past arg
    ;;
    *)
    print_usage
    exit 1
    ;;
  esac
  shift # past arg
done

if [ $DEPLOYMENT == "vsphere" ] || [ $DEPLOYMENT == "VSPHERE" ]; then
  DRIVER=vmwarevsphere
  SWITCH=""
elif [ $DEPLOYMENT == "amazonec2" ] || [ $DEPLOYMENT == "AMAZONEC2" ]; then
  DRIVER=amazonec2
  SWITCH=
elif [ $DEPLOYMENT == "local" ] || [ $DEPLOYMENT == "LOCAL" ]; then
  # Windows - Use HyperV and determine HyperV virtual switch.
  if [[ $(uname -o) == "Msys" ]]; then
    if [[ -z "$SWITCH" ]]; then
      if [[ -z "$HYPERV_VIRTUAL_SWITCH" ]]; then
        echo "Error - No virtual switch provided."
        echo "Either use the -v option or set the HYPERV_VIRTUAL_SWITCH environment variable."
        print_usage
        exit 1
      else
        echo "Using env HYPERV_VIRTUAL_SWITCH=$HYPERV_VIRTUAL_SWITCH"
        SWITCH=$HYPERV_VIRTUAL_SWITCH
      fi
    fi

    DRIVER=hyperv
    SWITCH="--hyperv-memory 2048 --hyperv-virtual-switch $SWITCH"
  else
    # Non-Windows - Use Virtualbox and omit virtual switch.
    DRIVER=virtualbox
    SWITCH="--virtualbox-memory 2048"
  fi
else
  echo "Error - No valid deployment provided."
  echo "Use the -d option to set deployment to either local / vsphere / amazonec2"
  print_usage
  exit 1
fi

echo "========================================================================"
echo "  Creating node(s)"
echo "========================================================================"

for i in $(seq 1 $MANAGERS); do
    echo "-> Creating $USERNAME-docker-manager$i machine ...";
    # Do not create managers in parallel if certificates does not exist (generated on first docker-machine create)
    if [ ! -f ~/.docker/machine/certs/ca.pem ]; then
      docker-machine create -d $DRIVER $SWITCH --engine-opt experimental=true --engine-opt metrics-addr=0.0.0.0:4999 --engine-label env=qliktive $USERNAME-docker-manager$i
    else
      docker-machine create -d $DRIVER $SWITCH --engine-opt experimental=true --engine-opt metrics-addr=0.0.0.0:4999 --engine-label env=qliktive $USERNAME-docker-manager$i &
    fi
done

for i in $(seq 1 $WORKERS); do
   echo "== Creating $USERNAME-docker-worker$i machine ...";
   docker-machine create -d $DRIVER $SWITCH --engine-opt experimental=true --engine-opt metrics-addr=0.0.0.0:4999 --engine-label env=qliktive $USERNAME-docker-worker$i &
done

echo "========================================================================"
echo "  Waiting for node(s) to be up and running"
echo "========================================================================"
wait

echo "========================================================================"
echo "  Init manager1 as the swarm manager"
echo "========================================================================"
eval $(docker-machine env $USERNAME-docker-manager1)

if [ $DRIVER == "amazonec2" ]; then
  MANAGERIP=$(docker-machine inspect --format '{{.Driver.PrivateIPAddress}}' $USERNAME-docker-manager1)
else
  MANAGERIP=$(docker-machine ip $USERNAME-docker-manager1)
fi

docker swarm init --advertise-addr $MANAGERIP --listen-addr $MANAGERIP:2377

MANAGERTOKEN=$(docker swarm join-token -q manager)
WORKERTOKEN=$(docker swarm join-token -q worker)

for node in $(seq 1 $WORKERS); do
    echo "-> worker$node joining swarm as worker ..."
    docker-machine ssh $USERNAME-docker-worker$node "sudo docker swarm join --token $WORKERTOKEN $MANAGERIP:2377"
done

echo "========================================================================"
echo "  Increase available virtual memory on manager nodes due to ELK stack"
echo "========================================================================"

for i in $(seq 1 $MANAGERS); do
  # Set initial value
  echo "-> Increasing virtual memory vm.max_map_count on node manager$i for elasticsearch"
  docker-machine ssh $USERNAME-docker-manager$i "sudo sysctl -w vm.max_map_count=262144"

  if [ $DRIVER == "amazonec2" ]; then
    # Add to conf so the setting is not lost after a reboot
    docker-machine ssh $USERNAME-docker-manager$i "echo sysctl -w vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf"
  else
    # Add to boot2docker profile so the setting is not lost after a reboot
    docker-machine ssh $USERNAME-docker-manager$i "echo sysctl -w vm.max_map_count=262144 | sudo tee -a /var/lib/boot2docker/profile"
  fi

done

echo "========================================================================"
echo "  STATUS"
echo "========================================================================"
echo "-> list swarm nodes"
docker-machine ssh $USERNAME-docker-manager1 "sudo docker node ls"
echo
echo "-> list machines"
docker-machine ls
