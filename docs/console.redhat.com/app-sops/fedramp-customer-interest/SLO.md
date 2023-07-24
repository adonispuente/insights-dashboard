# FedRAMP customer interest SLOs

## SLO

API

* Availability: 90% of requests result in successful (non-5xx) response.
* Latency: 90% of requests services in <2000ms.
* ServiceNow incident completeness: 90% of requests in successful response.

## SLI

API Availability: `sum(rate(fci_http_server_requests_total{status_code!~"5.."}[{{window}}]))/sum(rate(fci_http_server_requests_total[{{window}}]))`

API Latency: `histogram_quantile(0.90,sum by (le) (rate(fci_http_server_request_duration_seconds_bucket[{{window}}])))`

ServiceNow incident completeness: `sum(fci_processed_ops_total)` and `sum(fci_successful_ops_total)`

## Dashboards

<https://grafana.stage.devshift.net/goto/loNiAOC4z?orgId=1>
