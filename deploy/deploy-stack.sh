#!/bin/bash

cd "$(dirname "$0")" # change execution directory due to use of relative paths

USERNAME=$(id -u -n)

# deploy data to all worker nodes so that it can be accessed locally:
./deploy-data.sh

echo -e "\n========================================================================"
echo "Deploying stack to docker swarm"
echo "========================================================================"

eval $(docker-machine env $USERNAME-docker-manager1)
docker stack deploy -c ../docker-compose.yml --with-registry-auth custom-analytics

GW=$(docker-machine ip $USERNAME-docker-manager1)
echo -e "\n$(docker service ls)"
echo -e "\n\033[1m\033[93mThen all the replicas for the service is started (this may take several minutes) - \033[0m"
echo -e "\033[1m\033[93mThe following routes can be accessed: \033[0m"
echo -e "CUSTOM ANALYTICS\t- http://$GW/hellochart/"
echo -e "KIBANA\t\t\t- http://$GW/kibana/"
echo -e "DOCKER VISUALIZER\t- http://$GW/viz/"
