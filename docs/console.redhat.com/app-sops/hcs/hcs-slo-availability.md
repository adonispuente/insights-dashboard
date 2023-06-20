# Hyrid Committed Spend Frontend Availability

## SLI description

We're measuring the uptime of the frontend container that warms the Akamai cache every 10 minutes. As the static file provider for the user interface we intend to have ninety five percent or higher successful responses over a month (28 day period). Essentially minimizing pod downtime which indicates a problem where the user interface may not be able to warm its cache and provide content to users.

## SLI Rationale

The main purpose of the Hybrid Committed Spend frontend is to provide customers visibility into their burndown of spend against their committed contract. This SLI codifies directly the user experience that successful uptime indicates a sign of health.

## Implementation details

We use the `up` metric as the base for this SLO.

Our frontend container is exposed through a route isolated to only Akamai traffic, which warms the frontend cache about every 10 minutes. A service montior routinely scrapes the assocaited kubernetes service where the caddyserver that provides the static file content and metrics responds back allowing us to determine a regular uptime.

## SLO Rationale

We acknowledge that a 5% error rate over a month may seem high but there are several dependent components including Clowder, the Frontend Operator, and Akamai. As this frontend container holds only static data and will only be used for cache warming requests every 10 minutes, its quite possible for this container to be unreachble for some periods of time without affecting the customer experience. We believe the greater than 95% API availability models current expectations of customers to date.

## Alerts

An alert for this availabilty check can be found in the following prometheus rules file (rule: App-HCS-Absent-In-Frontends):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/frontends/frontends.prometheusrules.yaml
