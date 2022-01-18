# Drift5xx
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
Customer facing API doesn't work properly so there's a visible outage in the service.

## Summary
This alert fires when drift api (comparison-report) returns error status code (5**). That means some fatal error appeared in API container (drift-backend).

## Access required
Console access to the cluster+namespace (crcp01ue1 + drift-prod) pods are running in.

## Steps
1. Log into the console / namespace and verify if all drift-backend-service pods are running and receiving requests.
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/drift-prod/pods
    - Click the pod and go to "Logs" in the tabs
    - Each pod should have a liveness probe running every 10 seconds: `GET /mgmt/v0/status HTTP/1.1" 200`
2. Inspect drift-backend-service pods logs and search for error logs.
    - In each pod's logs use browser's "find" feature to search for the following:
        - "Traceback"
        - "Error"
        - "500"
3. Check if any deployments or changes in the application happened closer to the time the error started.
    - In the list of pods for drift-prod, check the "Created" column to see if a recent update was made to the pod that may be causing the issue.
4. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/drift/app.yml
