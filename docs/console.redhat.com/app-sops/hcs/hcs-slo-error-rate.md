# Hyrid Committed Spend Frontend Error Rate

## SLI description

We're measuring the error rate of our frontend static content request response codes. As for the user interface, we intend to have 90% or higher successful responses over a month (28-day period). Essentially minimizing 500-599 error code responses which indicate a problem with the frontend not properly providing content to Akamai.

## SLI Rationale

The primary purpose of the Hybrid Committed Spend frontend is to provide customers visibility into their burndown of spend against their committed contract. This SLI directly codifies the user experience that successful data responses indicate a sign of health.

## Implementation details

We use the `caddy_http_request_errors_total` metric and `caddy_http_requests_total` metric as the base for this SLO.

Our frontend is exposed to Akamai from a container deployed on the console.redhat.com OpenShift cluster. All cache warming requests are routed through a service that captures all responses.

## SLO Rationale

We acknowledge that a 10% error rate over a month may seem high, but several dependent components exist, including Clowder, the Frontend Operator, and Akamai. As this frontend container holds only static data and will only be used for cache warming requests every 10 minutes, this container can experience intermittent errors for some periods without affecting the customer experience. We believe the greater than 90% frontend content availability models customers' current expectations to date.


## Alerts

An alert for this availability check can be found in the following Prometheus rules file (rule: App-Frontend-Response-Errors):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/frontends/frontends.prometheusrules.yaml
