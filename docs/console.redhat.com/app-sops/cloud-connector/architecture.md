# Service Description

The Cloud Connector service is designed to receive messages from internal clients and route the messages to the target machine which runs in the customer's environment.

# Components

Cloud-Connector consists of 2 main components:

MQTT message consumer - responsible for subscribing to the MQTT topics and putting the MQTT messages onto the kafka message queue
Kafka message consumer - responsible for consuming the MQTT messages off of the kafka queue and recording the connection state in the database
API server - responsible for passing messages from internal clients to the connected client via the MQTT broker

<img alt="Architecture diagram" src="https://github.com/RedHatInsights/cloud-connector/blob/1872dabbc6b8a5477a644db2091f66c1e214ca68/design/architecture.png"/>

### MQTT Broker

Cloud-Connector expects the MQTT broker to be configured to require mutually authenticated TLS.  The broker should use the CN from the subject of the cert as the MQTT identity/username.  The client will use the CN from the subject of the cert as the client-id while connecting.  This client-id will be used as a part of the topics for each client.  The broker should be configured to only allow the clients to publish and subscribe to their topics to protect against client crosstalk.

### MQTT Message Consumer

The MQTT message consumer's main responsiblity is reading messages from the MQTT topics and writing those messages to kafka.  The MQTT message consumer does as little processing of the message as possible.  Its responsibility is to read the messages from the MQTT broker as quickly as possible and to write those messages to kafka as quickly as possible.

The MQTT message consumer subscribes to the client's _/out_ topics using a wildcard instead of an explicit client-id.  This allows the MQTT message consumer to receive messages from all of the clients. 

When the MQTT message consumer writes message to kafka, it uses the MQTT client-id (which is read from the topic from the MQTT message's metadata) is used as the _Key_ for the kafka message.  The client id is used as a message key in order to main the ordering of the messages on the kafka message queue as all messages with the same key get sent to the same kafka partitions.

It is important to note that the MQTT message consumer must 1) use the same client-id when connecting to the MQTT broker and 2) set the MQTT _cleanSession_ flag to _false_ when connecting to the MQTT broker.  These 2 settings allow the broker to buffer messages intended for the Cloud-Connector MQTT consumer while the MQTT consumer is down.

### Kafka Message Consumer

The Kafka message consumer reads the messages from the kafka message queue and processes those messages.
The messages contain the state of the client connection (mainly either _online_ or _offline_).  The kafka
message consumer updates the connection state in the database based on the message content.

The Kafka message consumer is only an MQTT publisher.  The Kafka message uses the pod name as the MQTT client-id.

### API Server

The API server is responsible for allowing internal clients to pass messages to the connected clients via the MQTT broker.  When the API server receives a message, it looks up the connection details in the connection database.  If the connection is _online_, then the API server sends the message to the MQTT broker for delivery.

The API server is only an MQTT publisher.  The API server uses the pod name as the MQTT client-id.

# Routes

Cloud-Connector does not have an exposed OpenShift route.

# Dependencies
- MQTT broker - currently managed by Akamai.
- Kafka - used for communication with other services within the HCC platform
- 3scale web gateway - used to lookup customer account information based on client-id/certificate subject
- Amazon RDS for PostgreSQL - used to persist connection state records

# Service Diagram
<img alt="Architecture diagram" src="https://github.com/RedHatInsights/cloud-connector/blob/1872dabbc6b8a5477a644db2091f66c1e214ca68/design/architecture.png"/>

# Application Success Criteria
Receptor-Controller maintains bi-directional connections between the console.redhat.com application
platform and receptor nodes running on customer sites.  Receptor-Controller allows applications internal
to the console.redhat.com application platform to send messages to receptor nodes on customer sites.

# State
Receptor-Controller maintains open websocket connections to receptor nodes running customer sites.
These connections can be thought of as state as they can only exist on a single pod.  The connections
are tied to that pod for their lifetime.

The mapping between the receptor node-id and the pod where the websocket connection lives is state.
This state exists in Redis.

Receptor-Controller is built in such a way that if the redis instance is cleared, Receptor-Controller
will rebuild the connection mapping state.

# Load Testing
https://docs.google.com/document/d/1DFyiGX2eSO9W5sEZh4-FSoAUAelwxypgADV5UbEpZig/edit#heading=h.av9emkusr482

# Capacity

### Current Resource Usage
| Deployment | Replicas | CPU Limit (cores) | Memory Limit (MB) | Total CPU (core) | Total memory (MB) |
|------------|----------:|-------------------:|-------------------:|------------------:|-------------------:|
| mqtt-message-consumer | 1 | 0.5 | 512 | 0.5 | 512 |
| kafka-message-consumer | 3 | 0.5 | 512 | 1.5 | 1536 |
| api-server | 3 | 0.5 | 512 | 1.5 | 1536 |


### Resource Forecast (1yr out)
| Deployment | Replicas | CPU Limit (cores) | Memory Limit (MB) | Total CPU (core) | Total memory (MB) |
|------------|----------:|-------------------:|-------------------:|------------------:|-------------------:|
| mqtt-message-consumer | 1 | 0.5 | 512 | 0.5 | 512 |
| kafka-message-consumer | 3 | 0.5 | 512 | 1.5 | 1536 |
| api-server | 3 | 0.5 | 512 | 1.5 | 1536 |
