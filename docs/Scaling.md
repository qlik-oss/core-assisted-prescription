# Scaling

## Definition

We would like to validate that our use-case is able to scale to 100,000 simultaneous users.
We used AWS EC2 instances in the performance test.

## Execution

We used our performance tool located in this repository. Since we needed to create 100,000 sessions we had to create new machines on AWS to run the performance tool. We used four machines with the AWS instance type [m5.2xlarge.](https://aws.amazon.com/ec2/instance-types/m5/)

## Modifications

We added the following settings to the Linux kernel. These settings improve the performance mainly in scenarios where there are a large number of network connections and files opened concurrently.

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

We noticed that the Qix session service was using a lot of CPU and hence decided to replicate the service to 4 replicas. 


## Result

When running five nodes with engine on the instance [x1e.2xlarge](https://aws.amazon.com/ec2/instance-types/x1e/) we successfully had 100,000 users, with 10% of them doing selections every 20 seconds.
