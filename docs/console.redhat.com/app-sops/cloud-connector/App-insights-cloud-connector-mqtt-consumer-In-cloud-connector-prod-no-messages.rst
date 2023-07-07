App-insights-cloud-connector-mqtt-consumer-In-cloud-connector-prod-no-messages
==============================================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Cloud-Connector is an application used to pass work requests to clients
  running on customer's computers.  If cloud-connector is not receiving mqtt
  messages, then it is possible that cloud-connector will not know about
  customer's computers going online or offline.

Summary
-------

This alert fires when the Cloud-Connector mqtt consumer has not received a message
from the MQTT broker in over 30 minutes.

This is due to an issue on the MQTT broker.

Situation
- client connection to the MQTT broker fails
- client reconnects to the MQTT broker
- client connection is handled by the same broker instance as the original connection
- MQTT broker will determine that the original connection has been severed
    - MQTT broker removes the client's subscriptions (this removes the subscriptions associated with the old and new connection)

This results in no messages being delivered to the new connection, but the
client (cloud-connector mqtt consumer) does not know that there is an issue.


Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

- Restart the cloud-connector-mqtt-message-consumer pods

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
