# ROS SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Latency

## SLI
Availability: 1.00 - (sum(rate(api_3scale_gateway_api_status{exported_service="ros", status="5xx"}[28d])) / sum(rate(api_3scale_gateway_api_status{exported_service="ros"}[28d])))
Latency: avg_over_time(service:sli:latency_gt_2000:pctl10rate5m{exported_service="ros"}[28d])

## SLO
Availability:  90% of requests result in successful (non-5xx) response
Latency:  90% of requests services in <2000ms

## Rationale
The given SLIs were determined based on the necessary components of the ROS API and engine processor. The main function of the API is to serve HTTP requests. Database connection and successful operation, therefore, is paramount to the operability of the API on the whole.

## Dashboards
https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&var-datasource=crcp01ue1-prometheus&var-label=ros
