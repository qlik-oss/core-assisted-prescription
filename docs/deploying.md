# Deploying the use case

Deployment of the use case can be done both to the AWS environments and to a Swarm cluster provided by the developer. This section contains examples and step-by-steps for deployment into such different environments.

## Prerequisites

* `docker-machine` installed on host i.e. computer executing the deployment script
* Git bash/cmd running in administrator mode
* Copied [swarm.env.example](/swarm.env.example) to `swarm.env`

## Creating the swarm

By default the script will spin up `1 manager` node and `2 worker` nodes. When all nodes are up and running the script will finish by listing all the nodes.

Once you have `swarm.env` configured for your preferred deployment (see sections below), run:

```bash
$ ./swarm.sh create
```

### Using Hyper-V (Windows only)

1. Open Hyper-V Manager desktop app
2. In top right corner under 'Actions' choose Virtual Switch Manager
3. If you don't have a virtual network switch you should create a new one. Choose external connection and give it a proper name. The name of the network switch will be used when spinning up the local environment.

In `swarm.env`:

Set `DOCKER_DRIVER=hyperv` and modify the `HYPERV_` environment variables to match your setup (ensure `HYPERV_VIRTUAL_NETWORK_SWITCH` is set to the name you gave it in the steps above).

### Using VirtualBox

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Using VMWare VSphere

In `swarm.env`:

Set `DOCKER_DRIVER=vmwarevsphere` and modify the `VSPHERE_` environment variables to match your setup. For a list of _all_ VSphere variables you can use, please see the [Docker documentation](https://docs.docker.com/machine/drivers/vsphere/).

### Using AWS EC2

Please note that after deploying to AWS you need to open the https/443 port for external IPs and at least the ports specified in [Open protocols and ports between the hosts](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts). This is done through *AWS Console > EC2 > Security Groups (Select security group created by 'docker-machine') > Inbound (tab)*

The AMIs could differ between different AWS zones but could be found using [Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/).

In `swarm.env`:

Set `DOCKER_DRIVER=amazonec2` and modify the `AWS_` environment variables to match your setup. For a list of _all_ AWS variables you can use, please see the [Docker documentation](https://docs.docker.com/machine/drivers/aws/).

This deployment has been verified with:

```
export AWS_DEFAULT_REGION=eu-west-1
export AWS_AMI=ami-6c101b0a
export AWS_INSTANCE_TYPE=t2.medium
```

## Deploying the services

To deploy/update services in the pre-existing swarm (see previous step how to create a swarm), simply run:

```bash
$ ./swarm.sh deploy
```

The bash script will deploy the services defined in [docker-compose.yml](../docker-compose.yml) as well as the [logging](../docker-compose.logging.yml) and [monitoring](../docker-compose.monitoring.yml) stacks.

## Cleaning/removing a deployment

Cleaning up all deployed services (_excluding_ volumes created):

```bash
$ ./swarm.sh clean
```

To completely remove the nodes (including services):

```bash
$ ./swarm.sh remove
```

## Scale

Assuming that a swarm has been [created](#deploy) with a fixed set of manager and worker nodes, there might be a need for scaling the swarm either up or down in size. For this use-case the scaling is focused on the availability of nodes running with QIX Engine containers, hence we should scale worker nodes. New worker nodes that are joining the swarm will spin up a QIX Engine automatically, due to global mode set on QIX Engine service in [docker-compose.yml](../docker-compose.yml).

There is no logic handling of active sessions on nodes being scaled down, so in that case a refresh is needed to retrieve a new session from one of the remaining nodes.

Scaling is done by defining the total number of workers needed (i.e. how many QIX Engines you need). If you pass in a value lower than current number of workers, it will remove top bottom workers until the new value has been reached.

Set total workers to two:

```bash
$ ./swarm.sh workers 2
```

Example:

Your current deployment exists of four workers:

```
ca-worker1
ca-worker2
ca-worker3
ca-worker4
```

If you do `./swarm.sh workers 2`, workers `3` and `4` will be removed.

## Continuous Deployment

This section will just explain one way how CD (Continuous Deployment) can be implemented using Circle CI and docker machine. It seems that docker-machine isn't designed to be exported between computers but this use case has some scripts to help you out with the needed certificates and configurations.

The flow for CD will be as following:
- Create a swarm cluster from local machine (create-swarm-cluster.sh)
- Export and copy docker-machine configs to the swarm manager (deploy-docker-machine-conf.sh)
- Implement a deploy step in your CI build pipeline (will be explained below and found in ./.cirecleci/config.yml)

The CD steps requires some environment variables to be set:
- DOCKER_AWS_MANAGER_IP
- DOCKER_AWS_MANAGER_NAME
These are used by docker in the CI deploy step

The SSH key for the manager has also to be added to SSH Permissions for the CircleCI build

```
# Download and install docker-machine
curl -L https://github.com/docker/machine/releases/download/v0.12.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine

# Download and extract docker-machine configs from swarm manager
scp -o StrictHostKeyChecking=no ubuntu@${DOCKER_AWS_MANAGER_IP}:/home/ubuntu/*-docker-*.zip ~/
apt-get update
apt-get install unzip
for i in ~/*-docker-*.zip; do ./import-machine.sh "$i"; done;

# "reseting docker variables since previous CI tasks overrides environment variables"
export DOCKER_HOST="tcp://${DOCKER_AWS_MANAGER_IP}:2376"
export DOCKER_CERT_PATH="/root/.docker/machine/machines/${DOCKER_AWS_MANAGER_NAME}"
export DOCKER_MACHINE_NAME=${DOCKER_AWS_MANAGER_NAME}

# Deploy stack
./swarm.sh deploy
```
