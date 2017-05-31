#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd .. # needs to be run in root to get secrets corretly
./deploy/output-styles.sh

USERNAME=$(id -u -n)
MACHINE=$USERNAME-docker-manager1
MACHINEIP=$(docker-machine ip $MACHINE)

# deploy data to all worker nodes so that it can be accessed locally:
./deploy/deploy-data.sh

# create self-signed certificates for the manager node:
./deploy/create-certs.sh -a $MACHINEIP

echo -e "\n========================================================================"
echo "  Deploying stack to docker swarm"
echo "========================================================================"

eval $(docker-machine env $MACHINE)
docker stack deploy -c ./docker-compose.yml --with-registry-auth custom-analytics

echo -e "\n$(docker service ls)"
echo -e $BYellow"\nThen all the replicas for the service is started (this may take several minutes) -"$Reset
echo -e $BYellow"The following routes can be accessed:"$Reset
echo -e "CUSTOM ANALYTICS         - https://$MACHINEIP/hellochart/"
echo -e "KIBANA                   - https://$MACHINEIP/kibana/"
echo -e "DOCKER SWARM VISUALIZER  - https://$MACHINEIP/viz/"
