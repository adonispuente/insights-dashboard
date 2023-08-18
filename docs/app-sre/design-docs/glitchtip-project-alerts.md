# Design doc: Glitchtip Project Alert Integration

**Table of contents:**

[toc]

## Author/date

Christian Assing / August 2023

## Tracking JIRA

[APPSRE-7521](https://issues.redhat.com/browse/APPSRE-7521)

## Problem Statement

Glitchtip can act on incoming events and send notifications to external systems via email or webhooks. Emails are sent to the configured project team members. Webhooks are sent to a configured URL. The receiver can be a chat system like Slack, Discord, or other compatible systems.

Currently, the tenants can't manage project alerts via App-Interface and need **admin** access to the Glitchtip project to configure alerts themselves. Unfortunately, the **admin** access allows the tenant to configure the whole project and not only the alerts. Such an unwanted change happened recently and caused an outage of [Glitchtip itself](https://docs.google.com/document/d/1T1mvvuuJQKHAbj1icdqVM9_HnQfxQ9ySvPm9vZid7qM.).

## Goals

Allow tenants to manage project alerts via App-Interface and remove the need for **admin** access to the Glitchtip project.

## Non-objectives

Management of *Uptime Monitors*[^1]


## Proposal

### Schema changes

The `glitchtip-project-1.yml` schema will be extended by an `alerts` field:

```yaml
---
$schema: /dependencies/glitchtip-project-1.yml

...
alerts:
- $ref: <path to a /dependencies/glitchtip-alert-1.yml file>
# or inline; see /dependencies/glitchtip-alert-1.yml schema
- name: ...
  description: ...
  recipients: ...
```

The `glitchtip-alert-1.yml` schema will be defined as follows:

```yaml
---
$schema: /dependencies/glitchtip-alert-1.yml

labels: <map of string:string>

name: <string>
description: <string>

quantity: <positiv number>
timespanMinutes: <positiv number>

recipients:
- provider: email-project-members
- provider: webhook
  url: <string>
```

The alert is triggered if an event happens `quantity` times in `timespanMinutes` minutes.
Recipients can be all project members via email and multiple webhooks. The alert name is used as an identifier; this means renaming an alert will delete and recreate it.

## Alternatives considered

n/a

## Resources

* [Glitchtip design-doc](/docs/app-sre/design-docs/glitchtip.md)
* The [API documentation](https://app.glitchtip.com/docs/) is not beloved. Use the force and read the [source](https://gitlab.com/glitchtip/glitchtip-backend) ;)

## Milestones

1. Implement a Qontract-Reconcile integration that manages Glitchtip project alerts
1. Persist current manually configured Glitchtip project alerts in the App-Interface
1. Remove **admin** access to the Glitchtip projects for all tenants


[^1]: *Uptime monitors* are similar to the Blackbox exporter. It doesn't make sense to manage them via App-Interface. The tenant can use the [Service Endpoint Monitoring](/docs/app-sre/design-docs/service-endpoint-monitoring.md) instead.
