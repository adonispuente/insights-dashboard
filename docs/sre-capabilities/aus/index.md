# Advanced Upgrade Service SRE capabilities users

[TOC]

## Purpose

AppSRE manages a fleet of clusters with various workloads and various constraints on how these clusters continuously receive Openshift updates. Years of experience, high automation and strong tooling allowed AppSRE to turn cluster upgrades into a no-toil process.

The Advanced Upgrade Service (AUS) SRE capability provides the same powerful policy based  upgrade experience for any cluster in <https://console.redhat.com/openshift>.

## Requirements engineering

Before an upgrade policy can be defined, the requirements and constraints for cluster upgrades need to be elaborated with the tenant. Since AppSRE is going to create the policy in `app-interface` in most cases (see [Support model](#support-model)), proper discussion about the update requirements is crucial.

## Defining a policy

Extensive documentation about how policies work and how they can be defined, can be found on [The Source](https://source.redhat.com/groups/public/sre/wiki/advanced_upgrade_service_aus).



## Support model

The documentation on [The Source](https://source.redhat.com/groups/public/sre/wiki/advanced_upgrade_service_aus) describes the support model auf AUS.

The support model advices interested users to reach out to AppSRE via Jira or the `@sre-capabilities-enablement` slack handle in the [#sd-app-sre](https://redhat-internal.slack.com/archives/CCRND57FW) Slack channel.

## Responsibilities

The responsibilities of the user management service are defined [here](https://source.redhat.com/groups/public/sre/wiki/advanced_upgrade_service_aus#aus-responsibilities).


## SOPs

* [Onboard an OCM organization with AUS](./sops/onboard-an-ocm-organization.md)
