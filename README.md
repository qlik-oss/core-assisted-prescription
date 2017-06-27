# Qliktive Custom Analytics

[![CircleCI](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics.svg?style=svg&circle-token=087152b4808d5373a8dcbbe82c2ff352e463a3a2)](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics)

**Warning**: This repo is under heavy development. We cannot guarantee that it works as described yet. Use at your own risk.

Due to issues in the Docker binaries on Stable track (17.03), we require you to **use at least Docker 17.06 (currently in Edge track).**

## Introduction

This repository contains the implementation of the Qliktive use case called "Custom Analytics UI". It's about serving a data visualization UI on the web to many users based on one single QIX Engine document. The deployment is hosted on AWS and uses Docker Swarm for container orchestration. Read more about the background of the Qliktive use case [here](https://github.com/qlik-ea/info/).

This repository contains the service stack and various scripts and tools to deploy the stack to AWS environments, as well as being able to develop and test the use case locally on a developer machine.

## Getting Started

### Locally

Run the script: 
```sh
$ ./scripts/deploy-local.sh
```
Now you will have the application running locally and can be accessed at https://localhost/
Login on the page with: "admin" and "password". Read more about our secret handling [here](https://github.com/qlik-ea/qliktive-custom-analytics/blob/master/docs/secrets.md#docker-secrets)

More information about running locally [here](https://github.com/qlik-ea/qliktive-custom-analytics/blob/master/docs/developing.md#locally-without-docker-swarm)

### Swarm

Swarm setup guide can be found [here](https://github.com/qlik-ea/qliktive-custom-analytics/blob/master/docs/deploying.md#deploying-the-use-case)

### Live Environment

Try out our live application [--TODO INSERT LINK--](http://broken.link). This is hosted on AWS and is a deployment of our latest master build.

## Details

### Services

The use case consists of multiple services, based on Docker images developed in other repos. See the [docker-compose.yml](docker-compose.yml) file for detailed information on which services that are used.

### Routes

This use case is primarily about consuming a UI-based analytics website, and we provide only a few of the APIs to the end-user.

* **Analytics UI** - `/`, the default UI.
* **Kibana Dashboard** - `/kibana/`, use to view logs from the different services — only available if the logging stack is included during deployment.
* **Swarm Visualizer** - `/viz/`, use to see an overview of the deployment, and where services are running. Only available in Swarm mode.

### Ports

The following ports are exposed externally. Make sure you update your firewall to allow/decline access to these!

* **443** - Openresty, the externally facing gateway.
* **12201** - Logstash UDP input (temporarily needed since logdriver uses host network stack) - should not be accessible externally.

## Terminology

The terminology used in this documentation with regards to technologies, tools, services, and names can be found in [here](https://github.com/qlik-ea/info/blob/master/docs/terminology.md).

## Further reading

* [Developing](./docs/developing.md) - Information on the development environment for the use case.
* [Testing](./docs/testing.md) - Information on how the use case is tested and how to run tests.
* [Deploying](./docs/deploying.md) - Information on deploying the use case, both to AWS and to other Docker Swarm clusters.
* [Performance banchmarking](./docs/performance.md) - Information on how to do performance benchmarking on a deployment of the use case.
