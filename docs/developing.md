# Developing

Developing this use case consists mainly of

* Updating versions of existing services in the stack.
* Adding or removing services from the stack.
* Modifying utility scripts and/or configuration files used for development, testing, and deployment of the use case.

## Prerequisites

* Access to the `qlikea` Docker Hub organization.
* Docker installed (latest release).
* Logged in to Docker.
* Clone this repo.

## Running the stack

For development purposes, the stack can be run on a developer machine using the local Docker Engine or in any Docker Swarm cluster the developer provides. Utility scripts to set up such a Swarm cluster are provided in this repo.

### Locally without Docker Swarm

You need to generate certificates the first time you want to start this project

```sh
$ ./deploy/create-certs.sh -a localhost
```

Then, you can easily start this use case locally on a developer machine, without any Swarm cluster, by using `docker-compose`.

```sh
$ docker-compose up -d
```

This starts all services in detached mode (recommended). You access it at https://localhost/.

### With Docker Swarm

This repo contains scripts for deploying the stack to a Swarm cluster (typically VMs on the local machine hypervisor) and scripts to create such a Swarm cluster.

Read more about this in the [Deploying](./deploying.md) section.

You access it by going to the hostname or IP address of your manager VM node in a web browser. You can find this address by running `docker-machine ls`.

## CI/CD

All pushed commits to the `master` branch or feature branches trigger the Circle CI job and some basic testing is performed on the use case configuration.

On commits to `master` the Circle CI job also deploys the stack the AWS staging environment, where further more covering tests of the use case will take place. More on this can be found in the [Testing](./testing.md) section. (_This is not implemented yet_)

The Circle CI job for this use case can be found [here](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics).