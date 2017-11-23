# Developing

Developing this use case consists mainly of

* Updating versions of existing services in the stack.
* Adding or removing services from the stack.
* Modifying utility scripts and/or configuration files used for development, testing, and deployment of the use case.

## Prerequisites

* Access to the `qlikea` Docker Hub organization.
* Docker installed (latest release).
* Login to docker with your Docker hub account via the command line: 
```sh
$ docker login
```
* Clone this repo.

## Running the Stack

For development purposes, the stack can be run on a developer machine using the local Docker Engine or in any Docker
Swarm cluster the developer provides. Utility scripts to set up such a Swarm cluster are provided in this repo.

### Locally Without Docker Swarm

You can easily start the use case locally on a developer machine, without Docker Swarm, with:

```sh
$ ./local.sh deploy
```

The script uses `docker-compose` and the application can now be accessed at https://localhost/.

To bring the system down, run:

```sh
$ ./local.sh remove
```

### With Docker Swarm

This repo contains scripts for deploying the stack to a Docker Swarm cluster (typically VMs on the local machine
hypervisor) and scripts to create such a cluster.

Read more about this in the [Deploying to Docker Swarm](./deploying-swarm.md) section.

You access it by going to the hostname or IP address of your manager VM node in a web browser. You can find this address
by running `docker-machine ls`.

## CI/CD

All pushed commits trigger the [CircleCI job](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics) and tests are
run.

Commits pushed to the `master` branch are also deployed to the AWS live environment as the last step, under the
condition that tests pass.
