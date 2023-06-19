App-Pod-Restarts-In-Frontends
=============================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCS pods are crash looping which could impact customer viewing of data depending on the component crashing.

Summary
-------

This alert fires when pod restarts are occurring more than 5x/1h for the last 30 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to hybrid-committed-spend-ui (https://github.com/RedHatInsights/hybrid-committed-spend-ui)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR in the frontend operator
-  Check recent PR for changes made to the deployments
-  Check events for resource limits being hit and if so redeploy with increased limits
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
