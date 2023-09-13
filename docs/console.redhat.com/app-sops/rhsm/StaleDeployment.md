# Stale Deployment
Severity: High

## Impact

## Summary
This alert fires when the RHSM Subscriptions deployments are not progressing

## Access required
-  Console access to the cluster + namespace (crcp01ue1 + rhsm-prod) pods are running in.

## Steps
-  Log into the console / namespace
-  Look to see if there is a quota issue.  If so, increase quota as needed.
-  Look to see if there is a LimitRange issue with any of the pods.  If so,
   increase the memory or CPU limit via CPU_LIMIT or MEMORY_LIMIT
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
