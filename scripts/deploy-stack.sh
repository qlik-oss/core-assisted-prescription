#!/bin/bash

set -e

cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd .. # needs to be run in root to get secrets corretly
source ./scripts/output-styles.sh

print_usage () {
  echo
  echo "Usage:"
  echo "  deploy-stack.sh [-o <switch>] [-u <username>]"
  echo "  -o <overwrite> - Force deployment of data files to workers."
  echo "  -u <username>  - Possibility to override the username in machinename."
  echo
}

USERNAME=$(id -u -n)

while [[ $# -gt 0 ]]
do
  arg="$1"

  case $arg in
    -o)
    OVERWRITE="-o"
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

MACHINE=$USERNAME-docker-manager1
MACHINEIP=$(docker-machine ip $MACHINE)

# deploy data to all worker nodes so that it can be accessed locally:
./scripts/deploy-data.sh $OVERWRITE -u $USERNAME

echo
echo "========================================================================"
echo "  Deploying stack to docker swarm"
echo "========================================================================"

eval $(docker-machine env $MACHINE)
docker-compose -f docker-compose.yml -f docker-compose.logging.yml -f docker-compose.monitoring.yml pull
docker-compose -f docker-compose.yml -f docker-compose.logging.yml -f docker-compose.monitoring.yml config > docker-compose.prod.yml
docker stack deploy -c ./docker-compose.prod.yml --with-registry-auth custom-analytics

echo
echo "$(docker service ls)"
echo
echo "Then all the replicas for the service is started (this may take several minutes) -"
echo "The following routes can be accessed:"
echo "CUSTOM ANALYTICS         - https://$MACHINEIP/"
echo "KIBANA                   - https://$MACHINEIP/kibana/"
echo "DOCKER SWARM VISUALIZER  - https://$MACHINEIP/viz/"
