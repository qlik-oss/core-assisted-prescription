# Deploying the use-case

This document contains examples and step-by-steps for deployment into different environments.

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

There are a number of environment variables needed to deploy using vSphere e.g. username, passwords and network specific configurations. The needed variables are documented [here](https://docs.docker.com/machine/drivers/vsphere/). In our setup we resolve it by exporting the environment variables using a `.bash_profile`.

## Deploy

Step-by-step:

1. To spin up a environment there is a script [here](./create-swarm-cluster.sh). 
    For a local environment setup in Windows:
    ```bash
    $ ./deploy/create-swarm-cluster.sh -d local -v <virtual network switch name>
    ```
    And a local setup on Mac OS X using VirtualBox:
    ```bash
    $ ./deploy/create-swarm-cluster.sh -d local
    ```
    And to deploy to vsphere
    ```bash
    $ ./deploy/create-swarm-cluster.sh -d vsphere
    ```
    By default the script will spin up `1 manager` node and `2 worker` nodes. When all nodes are up and running the script will finish with listing all the nodes.

2. Now there are three VMs available in the setup, and the environment is ready for deployment. 
    ```bash
    $ ./deploy/deploy-stack.sh
    ```
    The bash script will deploy the services defined in [docker-compose.yml](../docker-compose-swarm.yml).

3. To remove the deployed stack, use the following script.
    ```bash
    $ ./deploy/remove-stack.sh
    ```
    Note that this does not remove any Docker volumes on the nodes.

4. To bring down the VMs (including services) you can use the script [remove-swarm-cluster.sh](./remove-swarm-cluster.sh). This script will work regardless if running a local or vSphere deployment.
    ```bash
    $ ./deploy/remove-swarm-cluster.sh
    ```

### Validating your deployment

There is a small set of [tests](./validate-swarm-cluster.sh) that can validate a running deployment that services etc. are deployed and running on correct nodes. This script will work regardless if running a local or vSphere deployment.

```bash
$ ./deploy/validate-swarm-cluster.sh
```
