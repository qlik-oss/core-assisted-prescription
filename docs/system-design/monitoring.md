# Monitoring

System monitoring is provided through [logging](#logging) and [metrics](#metrics).

## Logging

The backend implementation uses the [ELK stack](https://www.elastic.co) (Elasticsearch, Logstash, and Kibana), together
with [Filebeat](https://www.elastic.co/products/beats/filebeat) to provide access to logs.

The ELK set up is pretty straight forward. One dedicated Docker Swarm worker node runs the ELK components. Filebeat is
deployed as a global service, running on each node in the Swarm cluster. Thus, only one instance of Logstash is running.
Another common set up is to run Logstash on each node but since Filebeat is more light weight, system resources are
freed up for other things.

The system clock on the backend nodes must be set to the UTC 00:00 timezone (a.k.a Zulu), and events must be logged in
this timezone.

### Collaborating Components

#### Gateway

- Exposes the `/kibana` endpoint to all logged in users.
- Users must log in to access logs but no other special access rights are needed to view logs in Kibana.
- Requests to Kibana are forwarded to the Kibana service running on the ELK worker node to serve the Kibana UI.

#### ELK Stack

- Runs on a dedicated ELK worker node which frees up the Swarm Manager node which optimally should run as few services
  as possible.
- Logstash is configured to do some log filtering so that logs are output to Elasticsearch in a format that is as
  similar as possible between the different services.
- The [logstash.conf](../../configs/logstash/logstash.conf) configuration file sets up input and output options together
  with log filtering rules.
- The [kibana.yml](../../configs/kibana/kibana.yml) configuration file provides a small number of settings provided to
  Kibana.

#### Filebeat

- Runs as a global Docker Swarm service on all nodes in the cluster.
- Monitors the Docker Engine log files on the node it runs on. This makes it possible to also access logs using
  `docker logs` or similar.
- Forwards logs to the single Logstash instance running on the ELK worker node.
- The Filebeat configuration file [filebeat.yml](../../configs/filebeat/filebeat.yml), configures path to Docker log
  files, some JSON log handling attributes, and the URL to reach Logstash on.

### Stack Configuration

The ELK stack and Filebeat Docker Swarm services are declared separately in the
[docker-compose.logging.yml](../../docker-compose.logging.yml) Compose file.

## Metrics

_This section remains to be written_
