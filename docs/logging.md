# Logging

All services developed by Qlik will follow a pattern where all logging is sent to `stdout` and the format of the log message will be in JSON.

This allows you to pick up logs either by CLI
`docker logs <container id>` or use a log driver such as gelf to forward all logging to a service. This use case has a logstash service that transforms the log messages (if needed) and adds it to an Elasticsearch database. All messages can then be searched and visualized by kibana.

The system clock must be set for the UTC 00:00 timezone (a.k.a Zulu), and events must be logged in this timezone.

## Example configuration
```
qix-engine:
	image: qlikea/engine
	command: -S TrafficLogVerbosity=5 -S EnableTTL=1
	logging:
		driver: gelf
		options:
			gelf-address: udp://localhost:12201
```

### Verbosity of QIX engine logging

 The verbosity of different log types is set through command line parameters when starting the docker container.

 `command: -S TrafficLogVerbosity=5 `

| Name	| Description | Default verbosity value°|
| --- | --- | --- |
| SystemLogVerbosity | System log | 4 |
| AuditLogVerbosity	| Audit log |	0 |
| PerformanceLogVerbosity	| Performance log |	4 |
| SessionLogVerbosity	| Session log |	4 |
| TrafficLogVerbosity	| Traffic log |	0 |
| QixPerformanceLogVerbosity	| QixPerformance log |	0 |
| SmartSearchQueryLogVerbosity	| SmartSearchQuery log |	3 |
| SmartSearchIndexLogVerbosity	| SmartSearchIndex log |	3 |
| SSE	| Server side extension log |	4 |

° (Off =0, Fatal=1, Error=2, Warning=3, Info=4, Debug=5)

### Collect the logs

Depending on the deployment the logs are sent to `stdout` and can be collected in different ways. Amazon has CloudWatch (monitoring service for AWS cloud resources), there are 3rd party LAAS (logging as a service), e.g. [logit.io](https://logit.io/) and in this use case we deploy the ELK° stack and use the [gelf logdriver](https://docs.docker.com/engine/admin/logging/gelf) to forward the log messages. Looking at the configuration above all messages sent to `stdout` will be picked up by the gelf driver and forwarded to `udp://localhost:12201` there logstash (on every node) will receive the messages, transform them and post them to the Elasticsearch database hosted on the manager node.

° ELK = Elasticsearch, Logstash and Kibana ([elastic](www.elastic.co))
