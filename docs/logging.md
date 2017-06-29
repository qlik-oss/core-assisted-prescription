# Logging



The system clock must be set for the UTC 00:00 timezone (a.k.a Zulu), and events must be logged in this timezone.

## Logging output
To ease the configuration the output from engine will be a json structure for each log type described below.

## Configuration
| Name	| Description | Default value |
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
