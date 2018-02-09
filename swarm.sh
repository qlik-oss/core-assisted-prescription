#!/bin/bash
# Add -x above to debug.

# We require a swarm.env file defining the environment variables needed to manage a swarm.
# If SKIP_SWARM_ENV is defined as 'true' however, we rely on those variables already
# being set in the environment.
if [ "$SKIP_SWARM_ENV" != "true" ] && [ ! -f $(dirname "$0")/swarm.env ]; then
  echo "You need to create a swarm.env file (or set SKIP_SWARM_ENV=true). Check docs/deploying-swarm.md for more information how to create and modify this file."
  exit 1
fi

# This trap is executed whenever a process exits within this script, we use it
# to output the exact command that failed to find potential issues faster.
exit_trap () {
  local lc="$BASH_COMMAND" rc=$?
  if [ "$rc" != "0" ]; then
    echo "Command [$lc] exited with code [$rc] - bailing"
    exit 1
  fi
}

trap exit_trap EXIT

# Move to project root to simplify execution context for processes.
cd "$(dirname "$0")"

if [ "$SKIP_SWARM_ENV" != "true" ]; then
  # Read environment variables configuration from swarm.env.
  set -o allexport; source ./swarm.env; set +o allexport
fi

set -e

command=$1
rest=${@:2}
user=$(id -u -n)
machine_prefix="${user}-ca"
switches="--driver=$DOCKER_DRIVER --engine-opt log-opt="max-size=10m" --engine-opt experimental=true --engine-opt metrics-addr=0.0.0.0:4999 --engine-label env=qliktive"
machines=
managers=
engine_workers=
elk_workers=

# Override default node name prefix if the user wants to.
if [ "$DOCKER_PREFIX" != "" ]; then
  machine_prefix=$DOCKER_PREFIX
fi

# Some parts of this script may need to refresh our swarm node list (e.g. when creating
# or removing nodes), this function simplifies it.
function refresh_nodes() {
  machines=$(docker-machine ls --filter label=env=qliktive -q)
  managers=$(echo "$machines" | grep -i 'manager' || true)
  engine_workers=$(echo "$machines" | grep -i 'engine-worker' || true)
  elk_workers=$(echo "$machines" | grep -i 'elk-worker' || true)

  echo "Managers found:"
  echo "$managers"
  echo "ELK workers found:"
  echo "$elk_workers"
  echo "Engine workers found:"
  echo "$engine_workers"
}

# Deploy the data we need to all worker nodes for easy directory mapping
# into the Qlik Associative Engine containers.
function deploy_data() {
  if [ -z "$engine_workers" ]; then
    echo "No qliktive worker nodes to deploy data against."
    exit 0
  fi

  for engine_worker in $engine_workers
  do
    echo "Deploying data to $engine_worker"
    driver=$(docker-machine inspect --format '{{.DriverName}}' $engine_worker)

    if [ $driver == "amazonec2" ]; then
      # Creating '/home/docker' on aws nodes.
      docker-machine ssh $engine_worker "sudo install -g ubuntu -o ubuntu -d /home/docker"
    fi

    docker-machine scp -r ./data $engine_worker:/home/docker/
  done
}

# Deploy the full swarm stack, including logging and monitoring stacks to the
# pre-existing qliktive swarm nodes.
function deploy_stack() {
  if [ -z "$machines" ]; then
    echo "No qliktive nodes to deploy against."
    exit 0
  fi

  ACCEPT_EULA=$ACCEPT_EULA AUTH_STRATEGY=$AUTH_STRATEGY JWT_SECRET=$(cat ./secrets/JWT_SECRET) docker-compose -f docker-compose.yml -f docker-compose.logging.yml -f docker-compose.monitoring.yml config > docker-compose.prod.yml
  docker-compose -f docker-compose.prod.yml pull

  for manager in $managers
  do
    ip=$(docker-machine ip $manager)
    eval $(docker-machine env $manager)
    docker stack deploy -c ./docker-compose.prod.yml --with-registry-auth custom-analytics
    echo
    echo "$(docker service ls)"
    echo
    echo "Then all the replicas for the service is started (this may take several minutes) -"
    echo "The following routes can be accessed:"
    echo "CUSTOM ANALYTICS         - https://$ip/"
    echo "KIBANA                   - https://$ip/kibana/"
    echo "DOCKER SWARM VISUALIZER  - https://$ip/viz/"
    echo "GRAFANA                  - https://$ip/grafana/"
  done
}

# Clean a deployed stack from the qliktive swarm nodes.
function clean() {
  if [ -z "$managers" ]; then
    echo "No qliktive nodes to clean."
    exit 0
  fi

  for manager in $managers
  do
    eval $(docker-machine env $manager)
    docker stack rm custom-analytics
  done
}

# Simple validation checking if all services has the correct number of replicas
# running in the swarm.
function validate() {
  error=0

  for manager in $managers
  do
    replicas=$(docker-machine ssh $manager docker service ls --format \"{{.Name}}/{{.Replicas}}\")
    for replica in $replicas
    do
      name=$(echo $replica | cut -d \/ -f 1)
      running=$(echo $replica | cut -d \/ -f 2)
      total=$(echo $replica | cut -d \/ -f 3)
      if [ "$running" != "$total" ]; then
        echo "$name does not have the correct number of replicas running ($running running but expected $total)."
        error=1
      fi
    done
  done

  if [ "$error" == "0" ]; then
    echo "All services are running with the correct number of replicas."
  fi
}

# Create nodes (1 manager, 1 elk-worker, 2 engine-workers) and join them as a swarm.
function create() {
  if [ "$machines" ]; then
    echo "There are existing qliktive nodes, please remove them and try again."
    exit 0
  fi

  name="${machine_prefix}-manager1"

  AWS_INSTANCE_TYPE="${AWS_INSTANCE_TYPE_MANAGER:-$AWS_INSTANCE_TYPE_DEFAULT}" \
  docker-machine create $switches $name
  ip=$(docker-machine inspect --format '{{.Driver.PrivateIPAddress}}' $name)

  if [ "$ip" == "<no value>" ]; then
    ip=$(docker-machine ip $name)
  fi

  eval $(docker-machine env $name)
  echo "docker swarm init --advertise-addr $ip --listen-addr $ip:2377:"
  docker swarm init --advertise-addr $ip --listen-addr $ip:2377

  function create-elk-worker() {
  token=$(docker swarm join-token -q worker)

  name="${machine_prefix}-elk-worker"
  AWS_INSTANCE_TYPE="${AWS_INSTANCE_TYPE_ELK:-$AWS_INSTANCE_TYPE_DEFAULT}" \
  docker-machine create $switches --engine-label elk=true $name
  docker-machine ssh $name "sudo sysctl -w vm.max_map_count=262144"

  if [ $DOCKER_DRIVER == "amazonec2" ]; then
    # Add to conf so the setting is not lost after a reboot.
    docker-machine ssh $name "echo vm.max_map_count = 262144 | sudo tee -a /etc/sysctl.conf"
  else
    # Add to boot2docker profile so the setting is not lost after a reboot.
    docker-machine ssh $name "echo sysctl -w vm.max_map_count=262144 | sudo tee -a /var/lib/boot2docker/profile"
  fi

  docker-machine ssh $name "sudo docker swarm join --token $token $ip:2377"
  }

  create-elk-worker

  refresh_nodes

  rest=2
  engine-workers
}

# Remove all nodes related to this project.
function remove() {
  if [ -z "$machines" ]; then
    echo "No qliktive nodes to remove."
    exit 0
  fi

  docker-machine rm $machines
}

# Set the number of engine-worker nodes. Requires a number to be passed in, e.g.
# `./swarm.sh engine-workers 4` to set total number of engine-workers to 4.
function engine-workers() {
  if [ -z "$rest" ]; then
    echo "Please supply the total number of engine-worker nodes you need:"
    echo "swarm.sh engine-workers <number of total nodes>"
    exit 0
  fi

  if [ -z "$managers" ]; then
    echo "No manager node available, please create a swarm."
    exit 0
  fi

  total_workers=$rest
  current_workers=$(echo "$engine_workers" | grep '[^ ]' | wc -l | tr -d ' ')
  delta=$(($total_workers - $current_workers))

  function reduce_workers() {
    echo "Scaling engine-workers to $total_workers by removing $(($delta * -1))"
    for i in $(seq $(($total_workers + 1)) 1 $current_workers); do
      engine_worker="${machine_prefix}-engine-worker$i"
      echo "Removing $engine_worker"
      docker-machine ssh $engine_worker "sudo docker swarm leave"
      docker-machine ssh $manager "sudo docker node rm -f $engine_worker"
      docker-machine rm -f -y $engine_worker
    done
  }

  function increase_workers() {
    echo "Scaling engine-workers to $total_workers by adding $delta"
    ip=$(docker-machine inspect --format '{{.Driver.PrivateIPAddress}}' $manager)

    if [ "$ip" == "<no value>" ]; then
      ip=$(docker-machine ip $manager)
    fi
    eval $(docker-machine env $manager)
    token=$(docker swarm join-token -q worker)

    for i in $(eval echo "{$(($current_workers + 1))..${total_workers}}"); do
      name="${machine_prefix}-engine-worker$i"
      AWS_INSTANCE_TYPE="${AWS_INSTANCE_TYPE_WORKER:-$AWS_INSTANCE_TYPE_DEFAULT}" \
      docker-machine create $switches --engine-label qix-engine=true $name
      docker-machine ssh $name "sudo docker swarm join --token $token $ip:2377"
    done
  }

  for manager in $managers
  do
    if [[ $delta -lt 0 ]]; then
      reduce_workers
    elif [[ $delta -gt 0 ]]; then
      increase_workers
    else
      echo "There already are $total_workers engine-worker node(s)."
    fi
  done
}

function list() {
  echo "Managers:"
  echo "$managers"
  echo ""
  echo "ELK-Workers:"
  echo "$elk_workers"
  echo ""
  echo "Engine-Workers:"
  echo "$engine_workers"
  echo ""
  for manager in $managers
  do
    docker-machine ssh $manager docker service ls
  done
}

refresh_nodes

if   [ "$command" == "deploy" ];        then deploy_data && deploy_stack
elif [ "$command" == "deploy-data" ];   then deploy_data
elif [ "$command" == "deploy-stack" ];  then deploy_stack
elif [ "$command" == "clean" ];         then clean
elif [ "$command" == "validate" ];      then validate
elif [ "$command" == "create" ];        then create
elif [ "$command" == "remove" ];        then remove
elif [ "$command" == "engine-workers" ];then engine-workers
elif [ "$command" == "ls" ];            then list

else echo "Invalid option: $command - please use one of: deploy, clean, validate, create, remove, engine-workers, deploy-data, deploy-stack"; fi
