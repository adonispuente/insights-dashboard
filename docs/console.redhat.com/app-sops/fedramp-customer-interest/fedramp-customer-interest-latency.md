
# FedRAMP customer interest API Latency

## SLI description

We're measuring the proportion of our API response that take no longer than two seconds (2 seconds) and we intend to have ninety percent(90%) or higher proportion of responses take less than two seconds over a month (28 day period).

Note: The metric used for this calculation includes all requests, included error requests (5xx), there is no ability to filter the latency measurement by status code.

## SLI Rationale

The main purpose of FedRAMP customer interest is to act as a middleware to automate the incident creation process during FedRAMP customer onboarding. This SLI codifies directly the user experience that successful and fast responses of a ServiceNow incident. While depending on a few external systems (OCM API and ServiceNOW API) the availability of these services can affect the response time we have built our API.

## Implementation details

// TODO Check how the service exposed

Our API server is exposed (?) through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service, but we capture all API requests using Prometheus [Go client library](https://github.com/prometheus/client_golang) with bucketed histogram for the API response times. Leveraging this proportion we are able to define our SLO.

## SLO Rationale

We acknowledge that two seconds (2 seconds) response may seem high but there are several dependent components including 3Scale, OCM API, ServiceNOW API, and Akamai which are all in the network path for our API service and could add additional time to the request which could result in a request timing out. We believe the greater than 90% API response completing in under two seconds (2 seconds) models current expectations of customers.

## Alerts

// TODO Add the correct alert rule

An alert for this availability check can be found in the following prometheus rules file (rule: `[STAGE] FedRAMPCustomerInterestDown`):

https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheusrules/insights-fedramp-customer-interest.prometheusrules.yaml
