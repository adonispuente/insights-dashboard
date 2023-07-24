# Automation Hub Latency 

## SLI description

We're measuring the proportion of our API response that take longer than two seconds. As the user interface or customer browses or downloads collections using the API we intend to have ninety percent or higher proportion of responses take less than two seconds over a month (28 day period).

Note: The metric used for this calculation includes all requests, included error requests (5xx), there is no ability to filter the latency measurement by status code.

## SLI Rationale

The main purpose of Automation Hub is to provide a repository to search, browse, and download certified ansible collections. This SLI codifies directly the user experience that successful and fast responses indicates a sign of health.

## Implementation details

We use the `api_3scale_gateway_api_time_bucket` metric and `api_3scale_gateway_api_time_count` metric as the base for this SLO.

Our API server is exposed through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service and it captures all API requests including a total count per application and a bucketed historgram for the API response times. Leveraging this proportion we are able to define our SLO.

## SLO Rationale

We acknowledge that a 10% latency rate over a month may seem high but there are several dependent components including 3Scale, Red Hat SSO, the Entitlements Service, and Akamai which are all in the network path for our API service and could add additional time to the request which could result in a request timing out. We believe the greater than 90% API response completing in under two seconds models current expectations of customers to date.

## Alerts

An alert for this availabilty check can be found in the following prometheus rules file (rule: App-automation-hub-prod-latency-SLO):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/automation-hub-prod/automation-hub.prometheusrules.yaml
