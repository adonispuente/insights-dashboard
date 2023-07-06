# Cloud-Connector SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. MQTT Message Processing
3. Kafka Message Consumer
4. Pod Uptime

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of messages ingested from MQTT and delivered to kafka
3. Kafka lag for the `platform.cloud-connector.rhc-message-ingress` topic
4. Percentage of time that the pod remains in the UP state during the past 24h

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 95%` of mqtt messages consumed are placed onto kafka successfully
3. Duration of an increase in Kafka lag should not exceed 30 minutes
4. `> 95%` uptime

## Rationale
The given SLIs were determined based on the components belonging to the Cloud-Connector service. The service lets customers send messages to their on-premise computers. Cloud-Connector receives messages from on-premise computers in order to record availability of the devices.  Once these messages are processed, the availability of the computer can be determined and cloud-connector can send messages to the computer.  This requires a functioning internal API, RDS database, and kafka producer.
