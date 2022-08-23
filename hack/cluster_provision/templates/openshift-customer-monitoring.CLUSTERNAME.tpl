---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: openshift-customer-monitoring
description: App-SRE OpenShift Application monitoring

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/observability/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

managedResourceTypes:
- Secret
- PrometheusRule
- ServiceMonitor

openshiftResources:
# Observability

## Secrets
### Prometheus additional alertmanager config
### Defines what alertmanager Prometheus fires alerts to
- provider: vault-secret
  path: app-interface/global/observability/prometheus-additional-alertmanager-config
  version: 1
### Prometheus additional scrape config
### Defines any additional jobs that don't fit into the servicemonitor model
- provider: resource-template
  type: extracurlyjinja2
  path: /observability/prometheus/prometheus-app-sre-additional-scrapeconfig-federate-only.secret.yaml
### Alertmanager configuration
- provider: resource-template
  type: extracurlyjinja2
  path: /observability/alertmanager/alertmanager-instance.secret.yaml
  validate_alertmanager_config: true
  enable_query_support: true
  # Replace PHASE with app-sre for production and app-sre-staging for staging
  variables:
    jiralert_host: jiralert.{phase}.devshift.net

## Servicemonitors
### All managed Prometheus Operators
- provider: resource
  path: /observability/servicemonitors/prometheus-operators-production.servicemonitor.yaml

## Prometheus Rules
### Federated Kubernetes metrics
- provider: resource
  path: /observability/prometheusrules/kube-metrics.prometheusrules.yaml
### kube-metrics pod-crashlooping
- provider: resource-template
  type: extracurlyjinja2
  path: /observability/prometheusrules/kube-metrics-pod-crashlooping.prometheusrules.yaml.j2
  enable_query_support: true
### OCM metrics
- provider: resource
  path: /observability/prometheusrules/ocm-metrics.prometheusrules.yaml
### Prometheus mixin alerts
- provider: resource
  path: /observability/prometheusrules/prometheus-mixin.prometheusrules.yaml
### OLM alerts
- provider: resource
  path: /observability/olm/olm.prometheusrules.yaml
### App SRE prometheus PVC metrics
- provider: resource
  path: /observability/prometheusrules/kube-metrics-pvc-observability.prometheusrules.yaml
### Container Security Operator rules
- provider: resource
  path: /observability/prometheusrules/container-security-operator.prometheusrules.yaml

################## Add  any cluster-specific content below this line ##################
