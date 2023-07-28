# Design doc: Cluster OCM labels

[toc]

## Author/date

Christian Assing / July 2023

## Tracking JIRA

[APPSRE-8073 - cluster-ocm-labels](https://issues.redhat.com/browse/APPSRE-8073)

## Problem Statement

Our SRE capabilities support two different cluster-gathering methods:

1. Via OCM cluster subscription labels ("OCM labels")
1. Via App-Interface

Both approaches contradict each other; you can't use OCM labels on App-Interface managed clusters and vice versa.

The problem is that we have clusters (e.g., [insights clusters](/data/openshift/insights/)) defined in App-Interface but not fully managed by App-Interface. Using the SRE capabilities on those clusters is either not possible or complicated.


## Goals

1. Allow easy usage of all SRE capabilities on clusters defined in App-Interface but not fully managed with App-Interface.
1. Remove the need for two different cluster-gathering methods for SRE capabilities.

## Nongoals

n/a

## Proposals

Define OCM cluster labels in App-Interface and sync them to OCM.

```yaml
$schema: /openshift/cluster-1.yml

labels:
  service: app-sre

name: SAMPLE-CLUSTER

ocm-labels:
  sre-capabilities:
    rhidp: true
    user-mgmt:
      rover:
        authz:
          cluster-admins: i-am-groot

```

Will become

```bash
$ ocm get ${cluster_subscription_href}/labels
```

with the following output:

```json
{
  "items": [
    {
      "internal": false,
      "key": "sre-capabilities.user-mgmt.rover.authz.cluster-admins",
      "kind": "Label",
      "type": "Subscription",
      "value": "i-am-groot"
      ...
    },
    {
      "internal": false,
      "key": "sre-capabilities.rhidp",
      "kind": "Label",
      "type": "Subscription",
      "value": "enabled"
      ...
    }
  ],
  "kind": "LabelList",
  "page": 1,
  "size": 2,
  "total": 2
}
```

A dedicated `ocm-labels` attribute in the cluster definition allows us to properly validate the labels before syncing them to OCM, e.g., enforce the usage of the `sre-capabilities` label defined in the [service dev guidelines](https://service.pages.redhat.com/dev-guidelines/docs/sre-capabilities/framework/ocm-labels/).

The sync will be a one-way sync from App-Interface to OCM. To avoid conflicts with other services that might use OCM labels, we will only manage labels that are part of the schemas, e.g., `sre-capabilities`, and leave the rest untouched.

## Alternatives considered

n/a

## Resources

* [SRE Capabilities](https://source.redhat.com/groups/public/sre/wiki/sre_capabilities)
* [Design doc: Advanced Upgrade Service without app-interface](/docs/app-sre/design-docs/advanced-upgrade-service.md)
* [Design doc: [SRE Capability] Red Hat IDP](/docs/app-sre/design-docs/redhat-idp.md)

## Milestones

1. Adapt the [cluster schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/cluster-1.yml) and implement the sync logic as a [qontract-reconcile](https://github.com/app-sre/qontract-reconcile) integration.
1. Remove the App-Interface RHIDP flavor in favor of the OCM one.
