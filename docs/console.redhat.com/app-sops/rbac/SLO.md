# RBAC SLO details


## Availability

**SLI description:** 

The percentage of time the RBAC has been up as proportion of the 5xx requests out of the total number of requests

**SLI rationale:** 

RBAC is critical service for providing permission data for Platform services. RBAC outage results in the Platform-wide outage.

**SLI implementation:**

RBAC availability is calculated from metrics gathered through 3Scale Gateway.

**SLO rationale:** 

The percentage of time the RBAC has been up as an average of the last 28 days is higher than 99 %.

`avg_over_time(service:sli:status_5xx:pctl5rate5m{environment="prod", exported_service="rbac"}[28d]) > 0.99`


## Latency

**SLI description:** 

The percentage of the service requests durations under 500ms

**SLI rationale:** 

The latency of the RBAC service is crucial for the user experience of Platform. The values have been established and verified based on the p99 of the last 28 days (= 421ms).

`histogram_quantile(0.99, sum(rate(django_http_requests_latency_including_middlewares_seconds_bucket{namespace="rbac-prod"}[28d])) by (le))`.

**SLI implementation:** 

RBAC latency is calculated from metrics collected by Django.

**SLO rationale:** 

The proportion of the service request durations under 500 ms during the last 28 days is higher than 99 %.

`sum(rate(django_http_requests_latency_including_middlewares_seconds_bucket{le="0.5", namespace="rbac-prod"}[28d])) / sum(rate(django_http_requests_latency_including_middlewares_seconds_count{namespace="rbac-prod"}[28d])) > 0.99`


## Monitoring & Alerting:

- Grafana Dashboard: https://grafana.app-sre.devshift.net/d/TjP_nMWMk/operations-rbac-w-cpu 
- Prometheus alerts: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/rbac-prod/rbac.prometheusrules.yaml
