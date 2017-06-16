#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd .. # needs to be run in root to get secrets corretly
source ./scripts/output-styles.sh

USERNAME=$(id -u -n)
MACHINE=$USERNAME-docker-manager1
MACHINEIP=$(docker-machine ip $MACHINE)

while [[ $# -gt 0 ]]
do
  arg="$1"

  case $arg in
    -o)
    OVERWRITE="-o"
    shift # past arg
    ;;
    -r)
    FORCE="-r"
    shift
    ;;
  esac
  shift # past arg
done

# deploy data to all worker nodes so that it can be accessed locally:
./scripts/deploy-data.sh $OVERWRITE

# create self-signed certificates for the manager node:
./scripts/create-certs.sh $FORCE -a $MACHINEIP

echo
echo "========================================================================"
echo "  Deploying stack to docker swarm"
echo "========================================================================"

eval $(docker-machine env $MACHINE)
docker-compose -f docker-compose.yml -f docker-compose.logging.yml pull
docker-compose -f docker-compose.yml -f docker-compose.logging.yml config > docker-compose.prod.yml
docker stack deploy -c ./docker-compose.prod.yml --with-registry-auth custom-analytics

echo "\n$(docker service ls)"
echo "${BYellow}\nThen all the replicas for the service is started (this may take several minutes) -${Reset}"
echo
echo "${BYellow}The following routes can be accessed:${Reset}"
echo "CUSTOM ANALYTICS         - https://$MACHINEIP/"
echo "KIBANA                   - https://$MACHINEIP/kibana/"
echo "DOCKER SWARM VISUALIZER  - https://$MACHINEIP/viz/"
