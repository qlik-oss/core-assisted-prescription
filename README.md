# This project as been deprecated
The project will be kept here for reference only. The repo will not be continuously updated and supported. 


# Qliktive Assisted Prescription
[![CircleCI](https://circleci.com/gh/qlik-oss/core-assisted-prescription.svg?style=svg)](https://circleci.com/gh/qlik-oss/core-assisted-prescription)

This repository contains the implementation of a medical data web application called _Qliktive Assisted Prescription_.
_Qliktive_ is a fictive company used to showcase different solutions built using Qlik Core.

Qliktive Assisted Prescription provides some advanced analysis capabilities on drugs, treatments, and reactions.
It targets the world-wide population of doctors. Even if the audience is more or less predictable, some seasonal or
sudden epidemic events can affect the traffic.

## How Qlik Core Is Used

The application has a custom visualization web UI. The application uses Qlik Core on the backend to
serve multiple users with medical analysis capabilities using one single Qlik Associative Engine document. To balance the load,
multiple Qlik Associative Engine instances serve the same document, and users are assigned a Qlik Associative Engine instance based on a simple round-robin load balancer.

The application is hosted on AWS and uses Docker Swarm for container orchestration, but it could also be deployed to
other cloud providers if needed.

## Repository Contents

This repository contains

- Background information and rationale for the Qliktive Assisted Prescription application.
- Documentation on how to develop, test, and deploy Qliktive Assisted Prescription.
- The backend service stack built on Qlik Core, with additional services to host the web application, handle
  authentication, and to provide logging and monitoring capabilities.
- Various scripts and tools to deploy the stack, and to enable developing and testing locally on a developer
  machine.

## Getting Started

To run the stack, Docker stable version 17.06 or later is required. Development is supported on both Docker for
Windows and Docker for Mac.

Note that before you deploy, you must accept the [Qlik Core EULA](https://core.qlik.com/eula/) by setting the
`ACCEPT_EULA` environment variable.

If you are running Qlik Associative Engine under a license obtained from Qlik, the license information shall be provided
in the `LICENSES_SERIAL_NBR` and `LICENSES_CONTROL_NBR` environment variables. Omit these environment variables to run
the [Community Version](https://core.qlik.com/licensing/#community).

### Deploying to Local Docker Engine

The stack can be deployed to the local Docker engine (without Docker Swarm) using the [local.sh](./local.sh) script.
It uses `docker-compose`. Run:

```sh
$ ACCEPT_EULA=yes LICENSES_SERIAL_NBR=<serial nbr> LICENSES_CONTROL_NBR=<control nbr> ./local.sh deploy
```

Replace `<serial nbr>` and `<control nbr>` with proper license numbers provided by Qlik, or omit these environment
variables to run the [Community Version](https://core.qlik.com/licensing/#community).

The application can now be accessed at https://localhost. Login in with: "admin" and "password".

### Deploying to Docker Swarm

The stack can also be deployed to Docker Swarm using the [swarm.sh](./swarm.sh) script. More information on how to
deploy to Docker Swarm can be found [here](./docs/deploying-swarm.md).

### Live Environment

Try out the live demo of the application at [ap.qlikcore.com](https://ap.qlikcore.com/). It is hosted on AWS and is a
deployment of the latest master build. A GitHub account is needed to sign in to live demo application.

### Services

The application consists of multiple services, based on Docker images developed in other repos. There are several
Docker Compose files defining different parts of the stack:

- [docker-compose.yml](./docker-compose.yml) contains all mandatory services. This includes the Qlik Core services,
  the web server and gateway, and some other essential services.
- [docker-compose.override.yml](./docker-compose.override.yml) provides some overrides to
  [docker-compose.yml](./docker-compose.yml) for running the stack on the local Docker engine.
- [docker-compose.logging.yml](./docker-compose.logging.yml) contains services for logging, which is the ELK stack
  together with Filebeat.
- [docker-compose.monitoring.yml](./docker-compose.monitoring.yml) contains services for monitoring, which is
  Prometheus, Alertmanager, and Grafana, together with some assisting services to extract metrics from different parts
  of the deployment.
- [docker-compose.pregen-ssl.yml](./docker-compose.pregen-ssl.yml) contains secrets provided to the OpenResty web server
  for HTTPS communication. This is only used if the user has a "real" certificate signed by a root CA and does not use
  the self-signed certificate that OpenResty generates.

### Routes

The application provides a few different endpoints, serving different purposes:

- `/` - The Assisted Prescriptions main UI to be consumed by the end user.
- `/kibana` - The Kibana dashboard used to view logs from the different services — only available if the logging
  stack is included during deployment. Mainly to be consumed by sys admins.
- `/viz` - The Docker Swarm visualizer used to see an overview of the deployment, and where services are running.
  Only available in Swarm mode. Manly to be consumed by sys admins.
- `/grafana` - The metrics dashboard towards Prometheus. Used to see an overview of monitoring and performance of the
  deployed services. Only available if the monitoring stack is included during deployment. Mainly to be consumed by sys
  admins.

Since OpenResty serves the application over HTTPS, port 443 is used. To host the application, the firewall must allow
access to this port.

## Further Reading

Requirements on the Assisted Prescription application are given in:

- [Requirements](./docs/requirements.md)

A system design overview is given in:

- [System Overview](./docs/system-design/system-overview.md)

More information related to development can be found in:

- [Developing](./docs/developing.md) - Developing and running the application on a developer machine.
- [Testing](./docs/testing.md) - Information on how the application is tested and how to run tests.
- [Secrets](./docs/secrets.md) - Docker secrets and options for secret management in the application.
- [Deploying](./docs/deploying-swarm.md) - Information on deploying the application to Docker Swarm clusters,
  including AWS.
- [Performance Benchmarking](./docs/performance-benchmarking.md) - Information on how to do performance benchmarking on
  a deployment of the application.
