# Performance benchmarking

One of the main features of the Custom Analytics UI use case is to be able to manage a large number of users accessing the site.

A performance benchmarking tool is provided to simulate such a peak in user connections and to provide a measure on the capability of a deployment of the use case. The tool does not include loading of browser content, instead it focuses on making QIX Engine connections through the gateway.

The tool can be run directly as a Node.js command line tool, but the recommended way is to run it as a Docker container. To do so, run the following:

```sh
$ ./scripts/build-test-image.sh
$ ./scripts/run-perf-bench.sh -g localhost -m 1000 -d 60
```

This launches performance benchmarking against the gateway assumed to be reachable on `localhost` (`-g` option) with a user peak of 1000 users (`-m` option). The number of connections grows linearly and reaches the peak after the provided duration (`-d` option). A simple verification of the connections is made and then the users are disconnected and reaches zero users, also after the same duration of time.

_The performance benchmarking tool is under development._

Currently, there are a number of limitations:

* The tool does not yet make any real data manipulations towards the QIX Engine connections, to simulate actual user behavior.
* The tool does not yet provide and performance metrics of the deployment.
