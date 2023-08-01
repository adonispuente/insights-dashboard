# Hyrid Committed Spend Frontend Latency

## SLI description

We're measuring the proportion of our frontend response that takes over five seconds. As the user interface, we intend to have a 90% or higher proportion of responses take less than four seconds over a month (28-day period).

Note: The metric used for this calculation includes all requests, including error requests (5xx). There is no ability to filter the latency measurement by status code.

## SLI Rationale

The primary purpose of the Hybrid Committed Spend frontend is to provide customers visibility into their burndown of spend against their committed contract. This SLI directly codifies the user experience that successful and fast data responses indicate a sign of health.

## Implementation details

We use the `caddy_http_request_duration_seconds_bucket` metric and `caddy_http_request_duration_seconds_count` metric as the base for this SLO.

Our frontend is exposed to Akamai from a container deployed on the console.redhat.com OpenShift cluster. All cache warming requests are routed through a service, and it captures all requests, including a total count and a bucketed histogram for the static content response times. Leveraging this proportion, we are able to define our SLO.

## SLO Rationale

We acknowledge that a 10% latency rate over a month may seem high but there are several dependent components including Clowder, the Frontend Operator, and Akamai. As this frontend container holds only static data and will only be used for cache warming requests every 10 minutes, its quite possible for this container to respond slowly for some periods of time without affecting the customer experience. We believe the greater than 90% response completing in under five seconds models current expectations of customers to date.

## Alerts

An alert for this availability check can be found in the following Prometheus rules file (rule: App-Frontend-Latency):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/frontends/frontends.prometheusrules.yaml
