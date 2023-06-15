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
