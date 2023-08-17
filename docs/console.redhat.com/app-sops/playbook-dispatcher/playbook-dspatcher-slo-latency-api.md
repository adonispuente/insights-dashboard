# Playbook Dispatcher API Latency

## SLI description

We're measuring the percentage of HTTP POST requests that are taking less than 2 seconds to fulfill.
We intend to have this percentage value to be at least 95% over a month (28 days).

## SLI Rationale

The main objective of Playbook Dispatcher is to allow our customers to dispatch a playbook run request and to track the progress of the run.
This SLI codifies directly the user experience as a high percentage of fast response rates are a sign of good health.

## Implementation details

We are using the `echo_http_request_duration_seconds_bucket` with the `service="playbook-dispatcher-api"` filter as the base for this SLO.
This metric gives us the time in seconds taken to serve each requests.
We also use the `le` filter associated with this metric to determine the percentage of HTTP requests that takes less than 2 seconds to complete.

## SLO Rationale

We acknowledge that a 5% slow HTTP response over a month may seem high, but there are other services like RBAC, Cloud Connector, Sources etc., that we rely on to fulfill user requests.
Therefore, it is likely that ocationally we will take more than 2 seconds to fulfill some of our requests.
By having the request latency threshold set to 95%, we intend to ensure that we are ignoring the noise that may arise from our dependencies.

## Alerts

The `PlaybookDispatcherSLOLatencyAPI` alert in the following prometheus rules file is associated with this latency SLO:
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/playbook-dispatcher/playbook-dispatcher.prometheusrules.yaml
