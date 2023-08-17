# Playbook Dispatcher Availability

## SLI description

We're measuring the percentage of HTTP requests that are successful (e.g. not 500s).
We intend to have this percentage value to be at least 95% over a month (28 days).

## SLI Rationale

The main objective of Playbook Dispatcher is to allow our customers to dispatch a playbook run request and to track the progress of the run.
This SLI codifies directly the user experience as a high percentage of successful requests are a sign of health.

## Implementation details

We are using the `api_3scale_gateway_api_status` with the `exported_service="playbook-dispatcher"` filter as the base for this SLO.
This metric gives us the total number of requests coming into our service.
We also use the `status` filter associated with this metric to determine the percentage of successful HTTP requests over the specified window.

## SLO Rationale

We acknowledge that a 5% unsuccessful HTTP requests over a month may seem high, but the total number of HTTP request we receive daily is usually below twenty thousand, and averaging around ten thousand. By having the successful requests percentage threshold set to 95%, we intend to ensure that our customer's expectations are met whilst ignoring the occational hiccups that could be associated with one of the services we depend on.

## Alerts

The `PlaybookDispatcherSLOAvailability` alert in the following prometheus rules file is associated with this availability SLO:
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/playbook-dispatcher/playbook-dispatcher.prometheusrules.yaml
