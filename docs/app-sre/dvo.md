# Deployment Validation Operator

## Overview

The [Deployment Validation Operator](https://github.com/app-sre/deployment-validation-operator) (DVO) checks deployments and other resources against a curated collection of best practices. Under the hood, it continuously runs the static analysis tool [KubeLinter](https://github.com/stackrox/kube-linter).

This document described the AppSRE usage of DVO and the requirements from tenants on meeting deployment best practices, as may be subject to periodic changes.

## AppSRE Usage

AppSRE leverages DVO to enforce deployment best practices, in order to increase service reliability.

DVO is installed on every OSD cluster as part of [SDE-1113](https://issues.redhat.com/browse/SDE-1113).

This allows DVO to collect information for services running on each cluster and expose it as Prometheus metrics. These metrics can be viewed in Prometheus instances installed per cluster. Metrics have a prefix of `deployment_validation_operator_`.

By using dynamically generated [per-resource alert rules](/docs/app-sre/sop/catch-all-alerts-routing.md#generate-per-resource-alerts) (implemented in [APPSRE-4765](https://issues.redhat.com/browse/APPSRE-4765)) and [Jiralert](https://github.com/prometheus-community/jiralert), these alerts are translated to Jira tickets on the board that corresponds to the violating workload.

## Tenant requirements

Tenants are required to act on tickets created for their services in a timely manner in order to follow deployment best practices, leading to more reliable services.

This requirement is rooted in the AppSRE contract, under the Reliability section: https://app-sre.pages.redhat.com/contract/#service-reliability-deployment-best-practices

All DVO tickets can be found under the [AppSRE tenants DVO issues](https://issues.redhat.com/issues/?filter=12393531) Jira filter.

## Implementation

Those [prometheusrules*.yaml.j2](./resources/services/deployment-validation-operator/prometheusrules-latest_tag.yaml.j2) files, e.g. [deployment-validation-operator-latest-tag](./resources/services/deployment-validation-operator/prometheusrules-latest_tag.yaml.j2) are used to generated DVO alerts.

Those files roughly translates to:
```
for each cluster:
    for each namespace:
        create a ticket on violated DVO metrics
```

Each alert includes a `jiralert` label, which will tell Jiralert where to route the alert (now ticket) according to the service [escalation policy](./README.md#define-an-escalation-policy-for-a-service).

## Metrics

The following metrics are the ones used by AppSRE and are considered the best practices we follow.

This list is subject to change from time to time, and tickets will be created automatically upon changes to it.

### Included metrics

#### deployment_validation_operator_no_anti_affinity

Excluded resource kinds: CronJob, Job, ReplicaSet

More information: https://docs.kubelinter.io/#/generated/checks?id=no-anti-affinity

#### deployment_validation_operator_default_service_account

Excluded resource kinds: ReplicaSet
Excluded resource names (regex):
- `[0-9a-z]{63}` (OLM Jobs related to CSVs)
- `.*-catalog-[0-9a-z]{5}` (OLM Catalog Pods)

More information: https://docs.kubelinter.io/#/generated/checks?id=default-service-account

#### deployment_validation_operator_drop_net_raw_capability

Excluded resource kinds: Pod

More information: https://docs.kubelinter.io/#/generated/checks?id=drop-net-raw-capability

#### deployment_validation_operator_latest_tag

Excluded resource kinds: Pod

More information: https://docs.kubelinter.io/#/generated/checks?id=latest-tag

#### deployment_validation_operator_minimum_three_replicas

Excluded resource kinds: ReplicaSet

More information: https://docs.kubelinter.io/#/generated/checks?id=minimum-three-replicas

#### deployment_validation_operator_privileged_ports

More information: https://docs.kubelinter.io/#/generated/checks?id=privileged-ports

#### deployment_validation_operator_no_liveness_probe

Excluded resource kinds: CronJob, Job, ReplicaSet

More information: https://docs.kubelinter.io/#/generated/checks?id=no-liveness-probe

#### deployment_validation_operator_no_readiness_probe

Excluded resource kinds: CronJob, Job, ReplicaSet

More information: https://docs.kubelinter.io/#/generated/checks?id=no-readiness-probe

#### deployment_validation_operator_unset_cpu_requirements

Excluded resource names (regex):
- `[0-9a-z]{63}` (OLM Jobs related to CSVs)
- `.*-catalog-[0-9a-z]{5}` (OLM Catalog Pods)

More information: https://docs.kubelinter.io/#/generated/checks?id=unset-cpu-requirements

#### deployment_validation_operator_unset_memory_requirements

Excluded resource names (regex):
- `[0-9a-z]{63}` (OLM Jobs related to CSVs)
- `.*-catalog-[0-9a-z]{5}` (OLM Catalog Pods)

More information: https://docs.kubelinter.io/#/generated/checks?id=unset-memory-requirements

## Disable DVO checks

There are cases where a DVO validation fails, while there are good reasons for the validation not to be met.

Follow this [documentation](https://github.com/app-sre/deployment-validation-operator#disabling-checks) to disable DVO checks for specific workloads.

Specific checks can be disabled for an entire app as defined in app-interface by adding the metric name as a label, with a reason for disabling the check as the value. For example:
```yaml
---
$schema: /app-sre/app-1.yml


labels:
    deployment_validation_operator_no_anti_affinity: "this app cannot be set to anti affinity rules because X and Y"
```

## Reporting

DVO metrics are [periodically](https://github.com/app-sre/qontract-reconcile/blob/6086b8dde71d507743b5d285b68f32c77bab5d5f/helm/qontract-reconcile/values-internal.yaml#L429-L430) collected by a qontract-reconcile integration called [dashdotdb-dvo](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/dashdotdb_dvo.py) and added to [Dash.DB](https://github.com/app-sre/dashdotdb) for reporting purposes, such as [Grafana dashboards](https://grafana.app-sre.devshift.net/d/dashdotdb/dash-db) or [App reports](./data/reports).

## History

These tickets [used to be created manually](https://gitlab.cee.redhat.com/app-sre/contract/-/merge_requests/88) by AppSRE engineers as part of [SRE Checkpoints](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/process/sre_checkpoints.md). Before that, workloads used to be validated at deploy time using [Manifest Bouncer](https://github.com/app-sre/manifest-bouncer).
