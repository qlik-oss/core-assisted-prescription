# Scaling

## Definition
We would like to validate that our use-case is able to scale to 100k simultaneous users.

This setup will be run in AWS.

## Execution
We used our performance tool located in this repository. Since we needed to create 100k sessions we had to create new machines on AWS to run the performance tool. We ended up with 4 machines on the AWS instance m5.2xlarge. 

## Modifications
We added the following settings to the Linux kernel for improved performance: 
### /etc/security/limits.conf
``` bash 
root soft nofile 1000000
root hard nofile 1000000
* soft nofile 1000000
* hard nofile 1000000
```

### /etc/sysctl.conf
``` bash
    vm.max_map_count=262144
    fs.file-max=1000000
    fs.nr_open=1000000
    net.netfilter.nf_conntrack_max=1048576
    net.nf_conntrack_max=1048576
```

## Findings

### Gateway
When running the initial test, we were running with only one gateway service and directing all traffic to the node serving the gateway. That gateway drowned in requests, and ended up crashing. 
We then scaled the gateway to run "globally" in the cluster, so it would be deployed to each node. 

We kept on directing all our traffic to one node, and then have docker swarm loadbalance all the traffic via its ingress network. Now the gateway service didn't crash but the node that received all the traffic wasn't able to handle all the requests.  

We then added an [Application load balancer in AWS](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) to loadbalance over all our nodes. 

### Qix session service
We noticed that the Qix session service was using alot of CPU and hence decided to replicate the service to 4 replicas. 


## Result

We successfully had 100k users, with 10% of them doing selections every 20 seconds. 
