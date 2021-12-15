---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: app-sre-observability-per-cluster
description: namespace for the app-sre per-cluster observability stack

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/observability/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

managedRoles: true

sharedResources:
- $ref: /services/app-sre/shared-resources/quayio-pull-secret.yml
