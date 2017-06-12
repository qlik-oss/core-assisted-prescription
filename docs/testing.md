# Testing

End-to-end tests on the use case are configured to run periodically on the staging environment. Promotion to the production environment only takes place after all tests successfully pass in staging.

Note that according the [Qlik Elastic Testing Strategy](https://github.com/qlik-ea/info/blob/master/docs/testing-strategy.md), it is assumed that all services and components are fully tested in their own scope, before integrating them into a use case like this, or into a larger solution.

Testing on the use case/system level shall ensure that the collaboration of services in the stack fulfill the requirements of the use case.

## Testing the stack

There is a set of basic end-to-end tests for verifying QIX Engine using [enigma.js](https://github.com/qlik-oss/enigma.js/).

### Without Docker Swarm

To execute tests on a local setup without Swarm, i.e. the services were started using `docker-compose`

```sh
$ cd test
$ npm run test:e2e
```

### With Docker Swarm

To execute test in a Swarm deployment using the default naming convention from the ```create-swarm-cluster.sh```, run

```sh
$ cd test
$ npm run test:e2e:swarm
```

Or, by setting the environment variable SWARMMANAGER to a specific manager node by hostname or IP, and then run

```sh
$ SWARMMANAGER=<IP address or hostname> npm run test:e2e:swarm
```

### Circle CI

Circle CI makes use of remote docker spaces, hence the tests and data mounts must be containerized to be able to be executed from the job pipeline. To set up the environment and execute the test cases in the same scenario as performed in Circle CI just run:

```sh
$ ./scripts/run-e2e-tests-cci.sh
```
