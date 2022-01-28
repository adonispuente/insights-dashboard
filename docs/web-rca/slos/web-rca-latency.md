# Web RCA - Latency SLI/SLO

## SLI description

We are measuring the proportion of all the requests that were served faster than a threshold value.

## SLI Rationale

Web RCA, a tool that integrates with Status Board and other external systems like
JIRA and Bugzilla, is expected to provide incident tracking information to teams in Red Hat 
managing services through reliable and fast responses within a specified time
to maintain a good user experience.

## Implementation details

We count the number of non 500 error code (successful) API requests that have a request duration of less than or equal to 1 second and
divide it by the total number of all successful requests. It is measured using the following metrics:

- `api_inbound_request_duration_bucket` to get the requests that are less than or equal to 1 second and not status code 5xx
- `api_inbound_request_duration_count` to get the total number of requests

## SLO Rationale

The target response time for 95 percent of the requests should be less than 1[s].

## Alerts

The following are the multi-window, multi-burn-rate alerts that are associated with this SLO.

- WebRCALatencyBudgetBurn