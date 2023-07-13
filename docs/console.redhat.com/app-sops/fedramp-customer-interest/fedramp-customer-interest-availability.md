
# FedRAMP customer interest availability

## SLI description

We're measuring the error rate of our API response codes and we intend to have ninety percent(90%) or higher successful responses over a month (28 day period). Essentially minimizing 500-599 error code responses which indicate a problem with the API server not properly providing data.

## SLI Rationale

The main purpose of FedRAMP customer interest is to act as a middleware to automate the incident creation process during FedRAMP customer onboarding. This SLI codifies directly the user experience that successful responses indicates the successful creation of a ServiceNow incident.

## Implementation details

// TODO Check how the service exposed

Our API server is exposed (?) through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service, but we capture all API requests using Prometheus [Go client library](https://github.com/prometheus/client_golang).

## SLO Rationale

We acknowledge that a 10% error rate over a month may seem high but there are several dependent components including 3Scale, Red Hat SSO, the Entitlements Service, and Akamai which are all in the network path for our API service and could lead to errors unrelated to our API server directly or which could intermittently add additional time to the request which could result in a request timing out. Additionally some errors could occur due to pod rebalancing during cluster upgrade. We believe the greater than 90% API availability models current expectations of customers to date.

## Alerts

// TODO Add the correct alert rule

An alert for this availability check can be found in the following prometheus rules file (rule: `[STAGE] FedRAMPCustomerInterestDown`):

<https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheusrules/insights-fedramp-customer-interest.prometheusrules.yaml>
