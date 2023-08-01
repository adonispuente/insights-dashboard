App-HCS-Absent-In-Frontends
===========================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Hybrid Committed Spend APP provides customer spend burndown related to their HCS contract. If the frontend component is down or absent, then no data is available to customers from the UI.

Summary
-------

This alert fires when an HCS Frontednd pod is down or all pods are absent for 5 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to hybrid-committed-spend-ui (https://github.com/RedHatInsights/hybrid-committed-spend-ui)

Steps
-----

-  Log into the console / namespace and verify if frontend pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR within the Frontend operator
-  Check recent PR for changes made to the UI.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
