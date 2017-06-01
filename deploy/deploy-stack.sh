#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths
. ./output-styles.sh

USERNAME=$(id -u -n)

# deploy data to all worker nodes so that it can be accessed locally:
./deploy-data.sh

echo -e "\n========================================================================"
echo "  Deploying stack to docker swarm"
echo "========================================================================"

eval $(docker-machine env $USERNAME-docker-manager1)
docker stack deploy -c ../docker-compose.yml --with-registry-auth custom-analytics

GW=$(docker-machine ip $USERNAME-docker-manager1)
echo -e "\n$(docker service ls)"
echo -e $BYellow"\nThen all the replicas for the service is started (this may take several minutes) -"$Reset
echo -e $BYellow"The following routes can be accessed:"$Reset
echo -e "CUSTOM ANALYTICS         - http://$GW/hellochart/"
echo -e "KIBANA                   - http://$GW/kibana/"
echo -e "DOCKER SWARM VISUALIZER  - http://$GW/viz/"
