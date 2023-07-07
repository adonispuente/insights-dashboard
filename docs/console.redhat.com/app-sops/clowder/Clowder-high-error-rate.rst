Clowder-high-error-rate
=======================

Impact
------

Potentially be blocking app teams from testing or deploying their app in their
target environment.

Summary
-------

More than 50% of reconciliations have resulted in failure for at least ten
minutes.

Access required
---------------

- Console access to the cluster+namespace pods are running in.
- OLM access, thus dedicated-admin

Steps
-----

- Log into the console and check the `clowder-system` namespace to verify if pods are up, stuck, etc
- Check the `clowder-controller-manager` pod logs and events in the `clowder-system` namespace
- Analyze errors in clowder-controller-manager pod logs.
- Try to determine if root cause is user error or a clowder bug. If it is a user error, it will have 
  an `error failed to reconcile` message. If it is a golang panic with traceback message, it is a Clowder issue.

Escalations
-----------

Ping the DevProd team on Slack at #team-consoledot-devprod
