# Testing

End-to-end tests on the use case are configured to run periodically on the staging environment. Promotion to the
production environment only takes place after all tests successfully pass in staging. (_This is not implemented yet_)

Testing on the use case/system level shall ensure that the collaboration of services in the stack fulfill the
requirements of the use case.

## E2E tests

There is a set of basic end-to-end tests for verifying Qlik Associative Engine using
[enigma.js](https://github.com/qlik-oss/enigma.js/).

### Without Docker Swarm

To execute the same sanity E2E tests as on CCI, on a local setup without Swarm (i.e. using `./local.sh deploy`), run:

```sh
$ ./scripts/run-e2e-tests-cci.sh
```

### With Docker Swarm

To execute test in a Swarm deployment using the default naming convention from the `./swarm.sh create`, run:

```sh
$ cd test
$ npm run test:e2e:swarm
```

Or, by setting the environment variable `GATEWAY_IP_ADDR` to a specific manager node by hostname or IP, and then run

```sh
$ GATEWAY_IP_ADDR=<IP address or hostname> npm run test:e2e:swarm
```

### CircleCI

CircleCI makes use of remote docker spaces, hence the tests and data mounts must be containerized to be able to be
executed from the job pipeline. To set up the environment and execute the test cases in the same scenario as performed
in CircleCI just run:

```sh
$ ./scripts/run-e2e-tests-cci.sh
```
