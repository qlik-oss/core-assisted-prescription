# qliktive-custom-analytics

**Warning**: This repo is under heavy development. We cannot guarantee that it works as described yet. Use at your own risk.

## Status

[![CircleCI](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics.svg?style=svg&circle-token=087152b4808d5373a8dcbbe82c2ff352e463a3a2)](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics)

## Introduction

This repo contains the implementation of the Qliktive use case called "Custom Analytics UI". It's about serving a data visualization UI on the web to many users based on one single QIX Engine document. The deployment is hosted on AWS and uses Docker Swarm for container orchestration. Read more about Qliktive use case backgrounds [here](https://github.com/qlik-ea/info/).

The repository contains the service stack and various scripts and tools to deploy the stack to AWS environments, as well as being able to develop and test the use case locally on a developer machine.

## Terminology

The terminology used in this documentation with regards to technologies, tools, services, and names can be found in [here](https://github.com/qlik-ea/info/blob/master/docs/terminology.md).

## AWS deployment

The use case and the web UI being hosted on AWS can be reached at

**TODO: Provide link**

This is the _production_ environment of the deployment. This is a stable version that should work at all times. There is also a _staging_ environment, found at

**TODO: Provide link**

This is always updated on new commits to the `master` branch of this repo. Deployment and provisioning from staging to production is a manual operation and supported by the deployment scripts hosted in this repo.

### Services

The use case consists of multiple services, based on Docker images developed in other repos. See the [docker-compose.yml](docker-compose.yml) file for detailed information on which services that are used.

### Routes

This use case is primarily about consuming a UI-based analytics website, and we provide only a few of the APIs to the end-user.

* **Analytics UI**\* - `/`, the default UI
* **Hello Chart** - `/hellochart/`, a temporary UI to test the use-case until we have the Analytics UI in place.
* **Kibana Dashboard**\*\* - `/kibana/`, use to view logs from the different services.
* **Swarm Visualizer**\*\*\* - `/viz/`, use to see an overview of the Docker Swarm deployment, and where services are running.

_\* Not available yet._  
_\*\* Will require authentication and possibly special authorization rights in the future (these are currently accessible by everyone)._  
_\*\*\* Only available in Swarm mode._

### Ports

The following ports are exposed externally. Make sure you update your firewall to allow/decline access to these!

* **443** - Openresty, the externally facing gateway.
* **12201** - Logstash UDP input (temporarily needed since logdriver uses host network stack) - should not be accessible externally.

## Further reading

* [Developing](./docs/developing.md) - Information on the development environment for the use case.
* [Testing](./docs/testing.md) - Information on how the use case is tested and how to run tests.
* [Deploying](./docs/deploying.md) - Information on deploying the use case, both to AWS and to other Docker Swarm clusters.
* [Performance banchmarking](./docs/performance.md) - Information on how to do performance benchmarking on a deployment of the use case.
