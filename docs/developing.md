# Development

Developing this use case consists mainly of

* Updating versions of existing services in the stack
* Adding or removing services from the stack
* Modifying utility scripts and/or configuration files used for development, testing, and deployment of the use case

## Running the stack locally

Running the stack _locally_ means to to run all services in the stack on the local Docker Engine on the developer machine or in any Docker Swarm cluster the developer provides. Utility scripts to set up such a Swarm cluster are provided in this repo.

### Without Docker Swarm

You can easily start this use case locally, without any Swarm cluster, by using `docker-compose`.

```sh
$ docker-compose up -d
```

which starts all services in detached mode (recommended). You access it at http://localhost/. Read more in the [Routes section](#routes) about your available options.

### With Docker Swarm

This repo contains scripts for deploying the stack to a local Swarm cluster (typically VMs on the local machine hypervisor) and scripts to create such a Swarm cluster.

Read more about this in the [Deploying](./deploying.md) section.

You access it by going to the hostname or IP address of your manager VM node in a web browser. You can find this address by running `docker-machine ls`. Read more in the [Routes section](#routes) about your available options.

## CI/CD

The Circle CI job for this use case can be found [here](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics).

All pushed commits to the `master` branch or feature branches trigger the Circle CI job and some basic testing is performed on the use case configuration.

On commits to `master` the Circle CI job also deploys the stack the AWS staging environment, where further more covering tests of the use case will take place. More on this can be found in the [Testing](./testing.md) section.
