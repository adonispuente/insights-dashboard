# Payload Tracker SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Successful Payload Processing
3. Uptime

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of correctly-formatted messages ingested from Kafka, which are successfully processed in the past 24 hours.
Successful processing is defined as insertion of the message’s into the database. If Prometheus metrics are enabled, success is also contingent on the successful pre-processing and subsequent recording of the message’s contents for Prometheus.
3. Percentage of time that the pod remains in the UP state during the past 24h

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 95%` of consumed messages are processed successfully based on SLI success criteria
4. `> 95%` uptime

## Rationale
The given SLIs were determined based on the necessary components of the Payload Tracker Service. Not only does the service process messages from the Kafka topic, but it also must serve HTTP requests. Database connection and successful operation, therefore, is paramount to the operability of the service on the whole. The SLO error budgets were determined by author definition.

## Error Budget
Error budgets are determined based on the SOP for each objective.

## Classifications and Caveats
* SLIs which are bound to prometheus metrics are laden to the uptime of the service. If the service goes down for any reason, the metrics we are able to gather will be skewed by down period. Currently payload processing, database engine, and HTTP server metrics will be impacted by this issue.
* Due to the flow of data through the service, Kafka errors should occur ahead of database INSERT and UPDATE errors, since INSERTs and UPDATEs only occur after a message is read from the current kafka partition. It is important we maintain separation of these two error types when computing metrics in the service. Kafka errors should have no influence on SELECT type queries made in the api controllers.
