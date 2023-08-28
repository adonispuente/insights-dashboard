# Sources service - SLO details

## Availability

**SLI description:** 

Sources service error rate uptime = the percentage of time the Sources service has been up as proportion of the 5xx requests out of the total number of requests during the same period

**SLI rationale:** 

The availability of the Sources service is crucial for the user experience of the Platform, as it is utilized by many other services within the Platform.

**SLI implementation:**

Sources availability is calculated from metrics gathered through 3Scale Gateway.

**SLO rationale:** 

The percentage of time the Sources service has been up as an average of the last 28 days is higher than 95 %.

**Expression:**

`avg_over_time(service:sli:status_5xx:pctl5rate5m{exported_service="sources"}[28d]) > 0.95`


## Latency

**SLI description:** 

Sources service latency uptime = the percentage of the service requests durations under 500ms during the defined period

**SLI rationale:** 

The latency of the Sources service is crucial for the user experience of Platform because many other services depend on the Sources Service. The values have been established and verified based on the p95 of the last 28 days (= 477ms).

`histogram_quantile(0.95, sum(rate(api_3scale_gateway_api_time_bucket{exported_service="sources"}[28d])) by (le))`.

**SLI implementation:** 

Sources latency is calculated from metrics gathered through 3Scale Gateway.

**SLO rationale:** 

The Proportion of the service request durations under 500 ms during the last 28 days is higher than 95 %.

**Expression:** 

`sum(rate(api_3scale_gateway_api_time_bucket{le="0500.0", exported_service="sources"}[28d])) / sum(rate(api_3scale_gateway_api_time_count{exported_service="sources"}[28d])) > 0.95`


## Monitoring & Alerting:

- SLO document: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/insights/sources/slo-documents/sources.yml
- Grafana Dashboard: https://grafana.app-sre.devshift.net/d/zxZKNnAMz/sources
- Prometheus alerts: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/sources/sources.prometheusrules.yml
