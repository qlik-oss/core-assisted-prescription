# Qliktive Custom Analytics

[![CircleCI](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics.svg?style=svg&circle-token=087152b4808d5373a8dcbbe82c2ff352e463a3a2)](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics)

To run this use case it's required to use Docker stable version 17.06 or later.

## Introduction

This repository contains the implementation of the Qliktive use case called "Custom Analytics UI".
It's about serving a data visualization UI on the web to many users based on one single QIX Engine document.
The deployment is hosted on AWS and uses Docker Swarm for container orchestration. Read more about the background of the
Qliktive use case [here](https://github.com/qlik-ea/info/).

This repository contains the service stack and various scripts and tools to deploy the stack to AWS environments,
as well as being able to develop and test the use case locally on a developer machine.

## Getting Started

### Deploying to Local Docker Engine

The stack can be deployed to the local Docker engine (without Docker Swarm) using the
[local.sh](./local.sh) script. It uses `docker-compose`. Run:

```sh
$ ./local.sh deploy
```

The application can now be accessed at https://localhost/. Login in with: "admin" and "password".

More information:

- [Developing](./docs/developing.md) - Developing and running the application on a developer machine.
- [Secret handling](./docs/secrets.md) - Docker secrets and options for secret management in the application.

### Deploying to Docker Swarm

The stack can also be deployed to Docker Swarm using the [swarm.sh](./swarm.sh) script. More information on how to
deploy to Docker Swarm can be found [here](./docs/deploying-swarm.md).

### Live Environment

Try out our live application [here](https://ca.qliktive.com/). This is hosted on AWS and is a deployment of our latest
master build.

## Details

### Services

The use case consists of multiple services, based on Docker images developed in other repos.
See the [docker-compose.yml](docker-compose.yml) file for detailed information on which services that are used.

### Routes

This use case is primarily about consuming a UI-based analytics website, and we provide only a few of the APIs to the
end-user.

* **Analytics UI** - `/`, the default UI.
* **Kibana Dashboard** - `/kibana/`, used to view logs from the different services — only available if the logging
    stack is included during deployment.
* **Swarm Visualizer** - `/viz/`, used to see an overview of the deployment, and where services are running.
    Only available in Swarm mode.
* **Grafana** - `/grafana/`, used to see an overview of monitoring and performance of the deployed services.
    Only available if the monitoring stack is included during deployment.

### Ports

The following ports are exposed externally. Make sure you update your firewall to allow/decline access to these!

* **443** - Openresty, the externally facing gateway.
* **12201** - Logstash UDP input (temporarily needed since logdriver uses host network stack) -
    should not be accessible externally.

## Further reading

* [Developing](./docs/developing.md) - Information on the development environment for the use case.
* [Testing](./docs/testing.md) - Information on how the use case is tested and how to run tests.
* [Deploying](./docs/deploying-swarm.md) - Information on deploying the use case to Docker Swarm clusters,
    including AWS.
* [Performance benchmarking](./docs/performance.md) - Information on how to do performance benchmarking on a deployment
    of the use case.
