# Pyrra Runbook

## Problem Statement/Overview

A tool we relied on creating alerts for onboarding services has been deprecated and the AppSRE team was looking for another solution for our tenants. The [UI](https://promtools.dev/alerts/errors) for slo-libsonnet allows you to produce the burnrate for any alert you want to create and this allows the tenant to upload that information to app-interface. Pyrra is a SLO generator tool that allows you to create a very generic alert like you would in the UI and that generic alert is uploaded for you as well as creating those burnrate alerts. More information can be found on the [source code](https://github.com/pyrra-dev/pyrra).

## What is Pyrra

Pyrra is composed of three components which is the UI, the API, and the backend. 
- The UI displays the SLOs, error budgets, burn rates, and more
- The API delivers information about SLOs from a backend to the UI
- The backend that watches for new SLO objects and creates Prometheus rules for each object
    - Pyrra introduces two different types of backends, a filesystem or Kubernetes operator. The backend deployed by AppSRE is Kubernetes.

## How it works in the AppSRE space

- [Saas file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-pyrra.yaml) that controls the deployment
- [Namespace](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/pyrra.app-sre-stage-01.yml) file

Out in the openshift console, there are two pods that are associated with Pyrra within the `pyrra` namespace, which is the api and the backend pods.

## How to implement Pyrra

To have the entries display on Pyrra UI, you can upload a template in app-interface that is of kind `ServiceLevelObjective`. Below is an example for the file `pyrra-slo-test-prom-http.yaml`:

```
apiVersion: pyrra.dev/v1alpha1
kind: ServiceLevelObjective
metadata:
  labels:
    prometheus: app-sre
    role: alert-rules
  name: prometheus-http-errors
  namespace: openshift-customer-monitoring
spec:
  alerting: {}
  description: ""
  indicator:
    ratio:
      errors:
        metric: prometheus_http_requests_total{job="prometheus-app-sre",code=~"5.."}
      total:
        metric: prometheus_http_requests_total{job="prometheus-app-sre"}
  target: "99.99"
  window: 2w
```

You can then reference the ServiceLevelObjective template file:
```
- provider: resource
  path: /observability/pyrra-slo/pyrra-slo-test-prom-http.yaml
```

The Kubernetes operator will then catch that change and create a PrometheusRule as well as show that new entry within the Pyrra UI.

# Improvements and Ongoing Work

Note: At this time, Pyrra is not deployed anywhere other than app-sre-stage-01 and is currently used for testing purposes. Below are some of the to-dos for AppSRE in order to make the availability of the service ready and reach a wider audience.

- Implement Pyrra deployment in other AppSRE owned clusters
- Human-readable URLs for tenants
- Create a PR to pyrra's upstream repo to allow for unique Prometheus URLs for the Kubernetes backend instead of relying on localhost
- Create the necessary communication to our tenants about this tool if we choose to utilize this service
- Edit any documentation about SLOs to include this tool if we choose to utilize this service

## References and Links

- [Deployment repo](https://github.com/app-sre/pyrra-template) on AppSRE's Github
- Pyrra deployment [console view](https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/pyrra/core~v1~Pod) on app-sre-stage-01
- [SLO examples](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/pyrra-slo) deployed through app-interface
- Pyrra [endpoint](http://pyrra-api-pyrra.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com) for app-sre-stage-01
