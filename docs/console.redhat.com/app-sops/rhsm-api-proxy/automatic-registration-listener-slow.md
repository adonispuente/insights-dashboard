# automatic-registration-listener kafka processing too slow
Severity: Medium

## Impact
-  The listener is projected to leave too many events unprocessed in a one-hour window. Based on this projection, customers that are establishing a link between Red Hat and cloud provider accounts are unable to use certain features, such as automatic registration, and will not be automatically opted in to subscription watch in a timely manner.
## Summary
This alert fires when the processing rate is insufficient to handle the rate of incoming events
## Access required
-  Console access to the cluster + namespace (crcp01ue1 + rhsm-api-proxy-prod) pods are running in.

## Steps
-  Log into the console / namespace
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/rhsm-api-proxy-prod/pods
    - Evaluate if the service is processing message, but not fast enough scale the number of replicas for automatic-registration-listener service
-  Check if there are any available logs / events for automatic-registration-listener pods.
    - If any pods have available logs, use browser's "find" feature to search for Java stacktraces
-  Check if any deployments or changes in the application happened closer to the time the error started.
    - In the list of pods for rhsm-prod, check the "Created" column to see if a recent update were made
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.
## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/rhsm-api-proxy/app.yml
