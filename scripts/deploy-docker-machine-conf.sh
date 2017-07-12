#! /bin/bash

set -e
cd "$(dirname "$0")" # change execution directory due to use of relative paths
cd .. # needs to be run in root to get secrets corretly

Manager=$(docker-machine ls --filter name=manager1 --format {{.Name}})
MachinesSTR=$(docker-machine ls --format {{.Name}})
while read -r line; do Machines+=("$line"); done <<<"$MachinesSTR"

for Machine in "${Machines[@]}"
do
	#Creating a zip file with docker machine configuration
	./scripts/export-machine.sh $Machine

	#Uploading it to the manager
	echo "Copy the configuration to Swarm manager:"
	docker-machine scp ./$Machine.zip $Manager:/home/ubuntu/
	echo
done
