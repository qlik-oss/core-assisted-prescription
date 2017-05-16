#!/bin/bash

set -e

USERNAME=$(id -u -n)

eval $(docker-machine env $USERNAME-docker-manager1)

# Swarm setup i.e. number of managers resp. workers nodes
MANAGERS=$(docker-machine ls | grep -c "manager")
WORKERS=$(docker-machine ls | grep -c "worker")
echo "Docker swarm consists of $MANAGERS manager and $WORKERS worker nodes"

if [ $MANAGERS -eq 0 ] || [ $WORKERS -eq 0 ]; then
  echo "Could not find any manager and/or worker nodes on host"
  exit 1
fi

# Test Variables
ERRORS=0

# Name of services that should be part of the swarm
services+=("openresty" "engine" "logstash" "kibana" "viz" "elasticsearch" "mira" "qliktive-qix-session-service")
elk+=( "elasticsearch" "logstash" "kibana" )

# ----------------------------------
# Number of service replicas
# ----------------------------------
number_replicas() {
  local replicas=$(echo $1 | grep -o '[0-9]\/[0-9]')
  echo $replicas
}

# ----------------------------------
# Running services on a node
# ----------------------------------
running_services() {
	local services=$(docker-machine ssh $1 docker ps)
  echo $services
}

# ----------------------------------
# Expected replicas for a given service
# ----------------------------------
expected_replicas() {
  case $1 in
    "engine") echo $WORKERS ;;
    "logstash") echo $(($MANAGERS+$WORKERS)) ;;
    *) echo $MANAGERS
  esac
}

# ----------------------------------
# Verify the actual number of service replicas in swarm for each service
# ----------------------------------
echo -e "\n========================================================================"
echo " Running test 1 "
echo "========================================================================"
echo -e "\nVerifying number of replicas of each container in the swarm"
service_ls=$(docker-machine ssh $USERNAME-docker-manager1 docker service ls)
for key in ${services[@]}; do
  service=${key}
  expected_replicas=$(expected_replicas "$service")
  echo "**********************************************************************"
  echo -e "\nService with name $service should have $expected_replicas replica(s)"
  status=$(echo "$service_ls" | grep "$service")

  replicas=$(number_replicas "$status")
  echo -e "Actual number of replicas: $replicas"

  if [ "$replicas" = "$expected_replicas/$expected_replicas" ]; then
    echo "Number of replicas is correct!"
  else
    echo "Number of replicas is NOT correct!"
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify ELK stack in docker swarm on manager node
# ----------------------------------
echo -e "\n========================================================================"
echo " Running test 2 "
echo "========================================================================"
echo -e "\nVerify ELK stack services"

echo -e "\nOn the manager node one of each ELK stack service should be running"
services=$(running_services "$USERNAME-docker-manager1")

for key in ${elk[@]}; do
  if [ $(echo $services | grep -c "${key}") -ge 1 ]; then
      echo "Service ${key} is running"
  else
    echo "Service ${key} is NOT running!"
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify Logstash service in docker swarm on worker nodes
# ----------------------------------
echo -e "\n========================================================================"
echo " Running test 3 "
echo "========================================================================"
echo -e "\nOn each worker node one instance of logstash should be running"

for i in $(seq 1 $WORKERS); do
  echo -e "\nChecking services running on node: $USERNAME-docker-worker$i"
  worker_services=$(running_services "$USERNAME-docker-worker$i")

  if [ $(echo $worker_services | grep -c "logstash") -eq 1 ]; then
    echo "Logstash is running"
  else
    echo "Logstash is NOT running!"
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify engine service in docker swarm on worker nodes
# ----------------------------------
echo "========================================================================"
echo " Running test 4 "
echo "========================================================================"
echo -e "\nOn each worker node one instance of engine should be running"

for i in $(seq 1 $WORKERS); do
  echo -e "\nChecking services running on node: $USERNAME-docker-worker$i"
  worker_services=$(running_services "$USERNAME-docker-worker$i")

  if [ $(echo $worker_services | grep -c "engine") -eq 1 ]; then
    echo "engine is running"
  else
    echo "engine is NOT running!"
    ERRORS=$(expr $ERRORS + 1)
  fi
done


# ----------------------------------
# Test Result
# ----------------------------------
echo "**********************************************************************"

if [ $ERRORS -gt 0 ]; then
  echo "FAILED"
  exit 1
fi

echo "PASSED"

eval $(docker-machine env -u)
