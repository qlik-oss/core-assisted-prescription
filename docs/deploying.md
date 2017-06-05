# Deploying the use-case

Deployment of the use case can be done both to the AWS environments (_to be documented_) and to a Swarm cluster provided by the developer. This section contains examples and step-by-steps for deployment into such different environments.

## Prerequisites

* `docker-machine` installed on host i.e. computer executing the deployment script
* Git bash/cmd running in administrator mode

### Additional prerequisites for local deployment in Windows

1. Open Hyper-V Manager desktop app
2. In top right corner under 'Actions' choose Virtual Switch Manager
3. If you don't have a virtual network switch you should create a new one. Choose external connection and give it a proper name. The name of the network switch will be used when spinning up the local environment.

### Additional prerequisites for local deployment in OS X

1. Install VirtualBox

### Additional prerequisites for vSphere deployment

There are a number of environment variables needed to deploy using vSphere e.g. username, passwords and network specific configurations. The needed variables are listed in the [Docker documentation](https://docs.docker.com/machine/drivers/vsphere/). In our setup we resolve it by exporting the environment variables using a `.bash_profile`.

## Deploy

Step-by-step:

1. To spin up an environment, use the script [create-swarm-cluster.sh](../scripts/create-swarm-cluster.sh).

    For a local environment setup in Windows:
    ```bash
    $ ./scripts/create-swarm-cluster.sh -d local -v <virtual network switch name>
    ```
    And a local setup on Mac OS X using VirtualBox:
    ```bash
    $ ./scripts/create-swarm-cluster.sh -d local
    ```
    And to deploy to vsphere
    ```bash
    $ ./scripts/create-swarm-cluster.sh -d vsphere
    ```
    By default the script will spin up `1 manager` node and `2 worker` nodes. When all nodes are up and running the script will finish with listing all the nodes.

2. Now there are three VMs available in the setup, and the environment is ready for deployment. 
    ```bash
    $ ./scripts/deploy-stack.sh
    ```
    The bash script will deploy the services defined in [docker-compose.yml](../docker-compose.yml).

3. To remove the deployed stack, use the following script.
    ```bash
    $ ./scripts/remove-stack.sh
    ```
    Note that this does not remove any Docker volumes on the nodes.

4. To bring down the VMs (including services) you can use the script [remove-swarm-cluster.sh](../scripts/remove-swarm-cluster.sh). This script will work regardless if running a local or vSphere deployment.
    ```bash
    $ ./scripts/remove-swarm-cluster.sh
    ```

### Validating your deployment

There is a small set of tests in [validate-swarm-cluster.sh](../scripts/validate-swarm-cluster.sh) that can validate a running deployment that services etc. are deployed and running on correct nodes. This script will work regardless if running a local or vSphere deployment.

```bash
$ ./scripts/validate-swarm-cluster.sh
```

## Scale

Assuming that a swarm has been [created](#deploy) with a fixed set of manager and worker nodes, there might be a need for scaling the swarm either up or down in size. For this use-case the scaling is focused on the availability of nodes running with qix engine containers, hence we should scale worker nodes. New worker nodes that are joining the swarm will spin up a QIX Engine automatically, due to global mode set on QIX Engine service in [docker-compose.yml](../docker-compose.yml).

There is no logic handling of active sessions on nodes being scaled down, so in that case a refresh is needed to retrieve a new session from one of the remaining nodes.

To scale nodes up:

```bash
$ ./scripts/scale-workers.sh up <number of nodes>
```

or down:

```bash
$ ./scripts/scale-workers.sh down <number of nodes>
```

or with fixed set of nodes, regardless if scaling up or down:

```bash
$ ./scripts/scale-workers.sh <total number of nodes>
```
