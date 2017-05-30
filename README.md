# qliktive-custom-analytics

Read more about the use-case background [here](https://github.com/qlik-ea/info/tree/master/use-case-custom-analytics).

**Warning**: This repo is under heavy development, we cannot guarantee that it works as described yet. Use at your own risk.

This repo contains the Qliktive use-case we call "Custom Analytics UI". It's all about scaling a specific document, to many users (one engine, one document, many users), using Docker Swarm for cluster management.

## Status
[![CircleCI](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics.svg?style=svg&circle-token=087152b4808d5373a8dcbbe82c2ff352e463a3a2)](https://circleci.com/gh/qlik-ea/qliktive-custom-analytics)

## Services

See the [docker-compose.yml](docker-compose.yml) file.

## Setup

Before starting, make sure you have access to `qlikea` Docker Hub organization.

1. Install docker (or make sure you are using the latest Docker release)
2. Docker login
3. Clone this repository

## Starting it

### Local

You can easily start this use-case locally, without any Swarm deployment, by using `docker-compose`.

Simply run:

```bash
$ docker-compose up
```

or in detached mode (recommended):

```bash
$ docker-compose up -d
```

You access it at http://localhost/. Read more in the [Routes section](#routes) about your available options.

### Swarm (deployment)

This repository has a some scripts for deploying the stack to a remote or local Swarm.

Read more about this in the [deploy documentation](deploy/deploy.md).

You access it by going to the hostname or IP address of your manager node in a web browser. You can find this address by running `docker-machine ls`. Read more in the [Routes section](#routes) about your available options.

## Routes

This use-case is primarily about consuming a UI-based analytics website, and we provide only a few of the APIs to the end-user.

* Analytics UI\* \*\*: `/` - The default UI.
* Hello chart: `/hellochart/` - A temporary UI to test the use-case until we have the Analytics UI in place.
* Kibana dashboard\*\*: `/kibana/` - Use this to view logs from the different services.
* Swarm Visualizer\*\* \*\*\*: `/viz/` - Use this to see an overview of the Docker Swarm deployment, and which services are running where.

\* Not available yet.

\*\* Will require authentication and possibly special authorization rights in the future (these are currently accessible by everyone).

\*\*\* Only available in Swarm mode.

## Ports

The following ports are exposed externally. Make sure you update your firewall to allow/decline access to these!

* 80: Openresty (externally facing gateway).
* 12201: Logstash UDP input (temporarily needed since logdriver uses host network stack) - should not be accessible externally.

## Test

There is a set of basic e2e tests for verifying qix engine using enigma in either a local setup or in a swarm.

### E2E testing on a local setup

To execute e2e tests on a local setup i.e. use-case was started using `docker-compose`.

```bash
$ cd test
$ npm run test:e2e
```

### E2E testing in swarm

The test cases can also be executed against a swarm deployment by either using the default naming convention from the ```create-swarm-cluster.sh```.

```bash
$ cd test
$ npm run test:e2e:swarm
```

or by specifying a specific manager node by hostname or IP

```bash
$ SWARMMANAGER=<IP address or hostname> npm run test:e2e:swarm
```

## Terminology

The terminology used in our use-cases with regards to tools, services, and names can be found in [here](https://github.com/qlik-ea/info/blob/master/terminology.md).

## Orchestration & Deployment

<table>
  <tr>
    <th></th>
    <th colspan="4" style="text-align: center">Orchestration</th>
  </tr>
  <tr>
    <th rowspan="7">Deployment</th>
    <td></td>
    <td>Docker Swarm</td>
    <td>Kubernetes</td>
    <td>Marathon/Mesos</td>
  </tr>
  <tr>
    <td>AWS</td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Google</td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Azure</td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Docker Cloud</td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>vSphere</td>
    <td><a href="./deploy/deploy.md">Documentation</a></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>local</td>
    <td><a href="./deploy/deploy.md">Documentation</a></td>
    <td></td>
    <td></td>
  </tr>
</table>
