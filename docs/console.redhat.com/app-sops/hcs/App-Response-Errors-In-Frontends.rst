App-Frontend-Response-Errors
============================

Severity: Medium
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCS pods fail to respond with content which could impact customer viewing of data depending on if the responses cause missing static content to be returned to Akamai, disrupting the frontend from being displayed properly.

Summary
-------

This alert fires when error responses are observed with an error rate > 10% for 5 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to hybrid-committed-spend-ui (https://github.com/RedHatInsights/hybrid-committed-spend-ui)

Steps
-----

-  Log into the console/namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages with a severity of ERROR in the frontend operator
-  Check recent PR for changes made to the deployments
-  Check events for resource limits being hit, and if so, redeploy with increased limits
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
