App-insights-advisor-api-In-advisor-prod-Downtime-Quota-Reached
==================================================================

Severity: High
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for cloud.redhat.com

Impact
------

-  The Insights Advisor API has been unreachable for significant portions of the past 24 hours.

Summary
-------

This alert fires when the Insights Advisor API has downtime at or in excess of 5% of the past 24 hours.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the advisor-prod namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the containers if available

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
