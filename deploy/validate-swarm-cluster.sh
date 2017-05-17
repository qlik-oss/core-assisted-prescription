#!/bin/bash

set -e
cd "$(dirname "$0")" # change execution directory due to use of relative paths
. ./output-styles.sh

USERNAME=$(id -u -n)

eval $(docker-machine env $USERNAME-docker-manager1)

# Swarm setup i.e. number of managers resp. workers nodes
MANAGERS=$(docker-machine ls | grep -c "$USERNAME-docker-manager")
WORKERS=$(docker-machine ls | grep -c "$USERNAME-docker-worker")
echo -e $BYellow"Docker swarm consists of $MANAGERS manager and $WORKERS worker nodes"$Reset

if [ $MANAGERS -eq 0 ] || [ $WORKERS -eq 0 ]; then
  echo "Could not find any manager and/or worker nodes on host"
  exit 1
fi

# Test Variables
ERRORS=0

# Name of services that should be part of the swarm
services+=("openresty" "engine" "logstash" "kibana" "viz" "elasticsearch" "mira" "qliktive-qix-session-service" "redis")
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
echo "  Running test 1 "
echo "  Verifying number of replicas of each container in the swarm"
echo "========================================================================"

service_ls=$(docker-machine ssh $USERNAME-docker-manager1 docker service ls)
for key in ${services[@]}; do
  service=${key}
  expected_replicas=$(expected_replicas "$service")
  echo -e "\n\tService with name $service should have $expected_replicas replica(s)"
  status=$(echo "$service_ls" | grep "$service")

  replicas=$(number_replicas "$status")
  echo -e "\tActual number of replicas: $replicas"

  if [ "$replicas" = "$expected_replicas/$expected_replicas" ]; then
    echo -e $Green"\tNumber of replicas is correct!"$Reset
  else
    echo -e $Red"\tNumber of replicas is NOT correct!"$Reset
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify ELK stack in docker swarm on manager node
# ----------------------------------
echo -e "\n========================================================================"
echo "  Running test 2 "
echo "  Verify ELK stack services"
echo "========================================================================"

echo -e "\n\tOn the manager node one of each ELK stack service should be running"
services=$(running_services "$USERNAME-docker-manager1")

for key in ${elk[@]}; do
  if [ $(echo $services | grep -c "${key}") -ge 1 ]; then
      echo -e $Green"\tService ${key} is running"$Reset
  else
    echo -e $Red"\tService ${key} is NOT running!"$Reset
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify Logstash service in docker swarm on worker nodes
# ----------------------------------
echo -e "\n========================================================================"
echo "  Running test 3 "
echo "  On each worker node one instance of logstash should be running"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  echo -e "\n\tChecking services running on node: $USERNAME-docker-worker$i"
  worker_services=$(running_services "$USERNAME-docker-worker$i")

  if [ $(echo $worker_services | grep -c "logstash") -eq 1 ]; then
    echo -e $Green"\tLogstash is running"$Reset
  else
    echo -e $Red"\tLogstash is NOT running!"$Reset
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Verify engine service in docker swarm on worker nodes
# ----------------------------------
echo -e "\n========================================================================"
echo "  Running test 4 "
echo "  On each worker node one instance of engine should be running"
echo "========================================================================"

for i in $(seq 1 $WORKERS); do
  echo -e "\n\tChecking services running on node: $USERNAME-docker-worker$i"
  worker_services=$(running_services "$USERNAME-docker-worker$i")

  if [ $(echo $worker_services | grep -c "engine") -eq 1 ]; then
    echo -e $Green"\tEngine is running"$Reset
  else
    echo -e $Red"\tEngine is NOT running!"$Reset
    ERRORS=$(expr $ERRORS + 1)
  fi
done

# ----------------------------------
# Test Result
# ----------------------------------
echo -e $BWhite"\n========================================================================"$Reset
echo -e $BWhite"  System validation result"$Reset
echo -e $BWhite"========================================================================"$Reset

if [ $ERRORS -gt 0 ]; then
  echo -e $BRed"\n\tFAILED\n\n"$Reset
  exit 1
fi

echo -e $BGreen"\n\tPASSED\n\n"$Reset

eval $(docker-machine env -u)
