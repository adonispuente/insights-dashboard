
# FedRAMP customer interest request success rate

## SLI description

We're measuring the numbers of successfully created ServiceNow incidents that take no longer than two seconds (2 seconds) and we intend to have ninety percent(90%) or higher proportion of successfully responses over a month (28 day period).

## SLI Rationale

The main purpose of FedRAMP customer interest is to act as a middleware to automate the incident creation process during FedRAMP customer onboarding. This SLI codifies directly the user experience that successful and fast responses of a ServiceNow incident. While depending on a few external systems (OCM API and ServiceNOW API) the availability of these services can affect the response time we have built our API.

## Implementation details

// TODO Check how the service exposed

Our API server is exposed (?) through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service, but we capture all API requests using Prometheus [Go client library](https://github.com/prometheus/client_golang) with counter data types. Leveraging this proportion we are able to define our SLO.

## SLO Rationale

We acknowledge that ninety percent(90%) response proportion may seem small but there are several dependent components including 3Scale, OCM API, ServiceNOW API, and Akamai which are all in the network path for our API service and could add additional time to the request and affect to our API. We believe than 90% successful API responses completing in under two seconds (2 seconds) models current expectations of customers.

## Alerts

// TODO Add the correct alert rule

An alert for this availability check can be found in the following prometheus rules file (rule: `[STAGE] FedRAMPCustomerInterestDown`):

https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheusrules/insights-fedramp-customer-interest.prometheusrules.yaml
