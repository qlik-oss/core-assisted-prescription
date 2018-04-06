# Deploying to Docker Swarm

Deployment of the use case can be done both to the AWS environments and to a Docker Swarm cluster provided by the
developer. This section contains examples and steps for deploying to such environments.

## Prerequisites

* `docker-machine` installed on the host, i.e. the computer executing the [swarm.sh](../swarm.sh) script.
* bash running in administrator mode (Git Bash recommended on Windows).
* [swarm.env.example](/swarm.env.example) copied to `swarm.env`, and sonfigured correctly.

## Creating the Docker Swarm Cluster

Once `swarm.env` is configured for the preferred deployment (see sections below), run:

```bash
./swarm.sh create
```

By default, the script will spin up one _manager_ node and two _worker_ nodes. When all nodes are up and running the
script finishes by listing all the nodes.

### Using Hyper-V on Windows

1. Open the Hyper-V Manager desktop application.
1. In top right corner, under "Actions", choose Virtual Switch Manager.
1. If you don't have a virtual network switch you should create a new one.
    Choose external connection and give it a proper name.
    The name of the network switch will be used when spinning up the local environment.

In `swarm.env`:

- Set `DOCKER_DRIVER=hyperv`.
- Modify the `HYPERV_` environment variables to match your setup.
- Ensure `HYPERV_VIRTUAL_NETWORK_SWITCH` is set to the name you gave it in the steps above.

### Using VirtualBox

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Using VMWare VSphere

In `swarm.env`:

Set `DOCKER_DRIVER=vmwarevsphere` and modify the `VSPHERE_` environment variables to match your setup. For a list of
_all_ VSphere variables you can use, please see the
[Docker documentation](https://docs.docker.com/machine/drivers/vsphere/).

### Using AWS EC2

Please note that after deploying to AWS you need to open the https/443 port for external IPs and at least the ports
specified in
[Open protocols and ports between the hosts](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts).
This is done through *AWS Console > EC2 > Security Groups (Select security group created by 'docker-machine') >
Inbound (tab)*

The AMIs can differ between different AWS zones and can be found using
[Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/).

In `swarm.env`:

- Set `DOCKER_DRIVER=amazonec2`.
- Modify the `AWS_` environment variables to match your setup.

For a list of _all_ AWS variables you can use, please see the
[Docker documentation](https://docs.docker.com/machine/drivers/aws/).

This deployment has been verified with:

```sh
export AWS_DEFAULT_REGION=eu-west-1
export AWS_AMI=ami-6c101b0a
export AWS_INSTANCE_TYPE=t2.medium
```

## Deploying the Services

To deploy/update services in the pre-existing swarm (see previous step how to create a swarm), simply run:

```bash
./swarm.sh deploy
```

The bash script will deploy the services defined in [docker-compose.yml](../docker-compose.yml) as well as the
[logging](../docker-compose.logging.yml) and [monitoring](../docker-compose.monitoring.yml) stacks.

## Cleaning/Removing a Deployment

Cleaning up all deployed services (_excluding_ volumes created):

```bash
./swarm.sh clean
```

To completely remove the nodes (including services):

```bash
./swarm.sh remove
```

## Authentication Strategies

Two different authentication strategies are supported when deploying the stack to Docker Swarm. The strategy used is
determined by the environment variable `AUTH_STRATEGY` which is used when running `./swarm.sh deploy`. The two options
are:

- `AUTH_STRATEGY=local` - With this strategy, the `auth` service will authenticate logins against
    accounts defined in the Docker secret provided in the [ACCOUNTS](../secrets/ACCOUNTS) file.
- `AUTH_STRATEGY=github` - With this strategy, the `auth` service will authenticate logins against GitHub, where users
    are required to be members of the `qlik-oss` or `qlik-trial` organizations. For this, two additional secrets must be
    configured correctly, `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` (see below).

The `local` strategy is the default, and used if the `AUTH_STRATEGY` environment variable is not set.

If the `github` strategy is used, the secrets `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` must be configured
accordingly. When deploying the stack to the AWS live environment the `github` strategy is set in the CircleCI job,
and it is configured with the necessary information to set up these secrets.

More information on Docker Secrets management is available [here](./secrets.md).

## Scaling

Assuming that a swarm has been [created](#deploy) with a fixed set of manager and worker nodes, there might be a need
for scaling the swarm either up or down in size. For this use-case the scaling is focused on the availability of nodes
running with Qlik Associative Engine containers, hence we should scale worker nodes. New worker nodes that are joining the swarm will
spin up a Qlik Associative Engine automatically, due to global mode set on Qlik Associative Engine service in
[docker-compose.yml](../docker-compose.yml).

There is no logic handling of active sessions on nodes being scaled down, so in that case a refresh is needed to
retrieve a new session from one of the remaining nodes.

Scaling is done by defining the total number of workers needed (i.e. how many Qlik Associative Engines you need). If you pass in a
value lower than current number of workers, it will remove top bottom workers until the new value has been reached.

Set total workers to two:

```bash
./swarm.sh workers 2
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

This section will just explain one way how CD (Continuous Deployment) can be implemented using CircleCI and
`docker-machine`. It seems that docker-machine isn't designed to be exported between computers but this use case has
some scripts to help you out with the needed certificates and configurations.

The flow for CD will be as following:
- Create a swarm cluster from local machine (create-swarm-cluster.sh)
- Export and copy docker-machine configs to the swarm manager (deploy-docker-machine-conf.sh)
- Implement a deploy step in your CI build pipeline (will be explained below and found in ./.cirecleci/config.yml)

The CD steps requires some environment variables to be set:
- `DOCKER_AWS_MANAGER_IP`
- `DOCKER_AWS_MANAGER_NAME`
These are used by docker in the CI deploy step

The SSH key for the manager has also to be added to SSH Permissions for the CircleCI build

```sh
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
