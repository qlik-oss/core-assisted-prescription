# Performance Benchmarking

One of the main features of the Assisted Prescription application is to be able to manage a large number of users
accessing the site.

A performance benchmarking tool is provided to simulate such a peak in user connections and to provide a measure on the
capability of a deployment of the use case. The tool does not include loading of browser content, instead it focuses on
making QIX Engine connections through the gateway.

## Setup

Running the performance benchmarking requires that a deployment of the Qliktive Assisted Prescription application exists
at a known URL.

```sh
cd test/perf
npm install
```

## Running

Supported options:

```sh
 -g <URL to Assisted Prescription deployment> 
 -m <max number of users per thread>
 -d <delay between each added user>
 -t <number of threads to run on, (-1 will check os and return number of cores)>
 -s <number of ms between each round of new selections>
 -r <ratio of users that will perform a selection each round (ie 0.1 for 10% of the users>
 ```

Running with max 100 users per thread:

```sh
cd test/perf
node src/cluster.js -m 100
```
