# Cluster upgrades

The AppSRE clusters are automatically upgraded by an integration called `ocm-upgrade-scheduler`.

This document explains how the integration decides to upgrade a cluster.

Jira ticket: https://issues.redhat.com/browse/SDE-1376

## Overview

To enable upgrades for a cluster, add an `upgradePolicy` section to the cluster file:
```yaml
upgradePolicy:
  # types of workloads running on this cluster
  workloads:
  - workload1
  - workload2
  # cron expression to determine when upgrades should be scheduled
  schedule: 0 12 * * 1-5
  # conditions to decide if upgrade should be scheduled
  conditions:
    # number of days this version has been running in clusters with the same workloads
    soakDays: 0
```

## How it works

For each cluster with an `upgradePolicy`, we check that the following conditions are met:
- the cluster has no current upgrade pending.
- there are available versions to upgrade to.
- the upgrade schedule is within the next 2 hours.
- the version has been soaking in other clusters with the same workloads (more than `soakDays`).

The versions to upgrade to are iterated over in reverse order, so it is assumed that the latest version that meets the conditions is chosen.

The accounted soak days:
- are accumulated from all clusters running that workload on that version
- also account cluster/workload which have had that version running in the past
The more clusters have that version, the faster the number of soaking days is increasing.

Note that clusters also follow different upgrade channels. Clusters following different channels don't get the same version available at the same time.

## Version history

Information on how long a version has been running in our clusters can be found in the `version-history` app-interface-output page: https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/version-history.md

This page can be used to debug why certain upgrades are scheduled or not or to help with providing a signal for pre-release OCP versions.

## Block upgrades to versions

In order to block upgrades to specific versions, follow these steps:

1. Disable `ocm-upgrade-scheduler` in [Unleash](https://app-interface.unleash.devshift.net) to prevent any new upgrades to this version from being scheduled.
1. Add the version to the `blockedVersions` list in the OCM instance file.

Notes:

- Regex expressions are supported.
- These steps will also cause existing upgrades to be cancelled if time allows.
- All AppSRE clusters are provisioned in the [OCM production instance](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2860db033ff2cc88aadf6b655d8ced7ac66746d3/data/dependencies/ocm/production.yml#L18).


## Upgrade strategy

### Hive

The first clusters to be upgraded belong to the integration and SSO test environments (hivei01ue1, ssotest01ue1).

Once a version has soaked for 10 days, the stage clusters will be upgraded (hive-stage-01, hives02ue1).

Once a version has soaked for 20 days, it will begin rolling out to the production clusters. Start with the least critical ones:
- hivep04 will go first as it's a hot standby and holds no customer clusters.
- hivep06 is going to replace hivep03 (2 AZs), and currently also has no customer clusters
- hivep03 has very few customer clusters and is not being scheduled with any new ones until it's deprecation

All other Hive production clusters (01, 02, 05) hold most customer clusters and are the only ones being scheduled with new customer clusters.

We choose different soak days to give some interval between upgrades. Should anything go wrong - we will have some time to intervene, block versions, only handle one issue at a time, etc.

### AppSRE

The first clusters to be upgraded belong to the stage environment (app-sre-stage-01, appsres03ue1).

Once a version has soaked for 7 days, the production clusters will be upgraded (app-sre-prod-01, appsrep05ue1).

### CodeReady Dependency Analytics (CRDA)

The first cluster to be upgraded belongs to the stage environment (app-sre-stage-02).

Once a version has soaked for 3 days, the production cluster will be upgraded (app-sre-prod-03).

### console.redhat.com (CRC)

The first cluster to be upgraded belongs to the stage environment (crcs02ue1). It is upgraded once a week.

Once a version has soaked for 6 days, the production cluster will be upgraded (crcp01ue1).

### OCM

OCM runs on 3 clusters with 0 soakdays, getting upgrades from the candidate channel:
- app-sre-stage-01
- appsres04ue2
- ssotest01ue1

Then the production cluster app-sre-prod-04 will be upgraded from the stable channel after 18 soakdays. Since soakdays are cumulated with each cluster running the workload, the ocm soakdays number will grow fast: it should get upgraded after 18/3=6 days, provided the version is available in the stable channel. 

### OCM-Quay

The first clusters to be upgraded are the read-only ocm-quay clusters.

The first one is upgraded with every new version. The second after the version has soaked for a day, the third after 2 days.

Once a version has soaked for 7 days, the read-write clsuter will be upgraded.

### Quay

The first cluster to be upgraded is the stage environment cluster quays02ue1, on the candidate channel. It is upgraded with every new version.

Then the 2 production clusters are upgraded after
- 6 days for quayp04ue2 (stable channel).
- 11 days for quayp05ue1 (stable channel). This should allow some delay between the two clusters, even if the first one is being done late, on a Monday for example.

### Telemeter

The first cluster with telemeter workload is app-sre-stage-01 which also host other workloads (See [](#AppSRE)). This cluster will be upgraded on every new version in the candidate channel.

Then the telemeter-prod-01 cluster will be upgraded from the fast channel if the version remains up for 6 days.
