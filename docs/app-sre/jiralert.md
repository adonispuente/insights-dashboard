# Jiralert

## Overview

[Jiralert](https://github.com/prometheus-community/jiralert) implements Alertmanager's webhook HTTP API and connects to one or more JIRA instances to create highly configurable JIRA issues.

This document described the AppSRE usage of Jiralert.

## AppSRE Usage

AppSRE leverages Jiralert to enable routing of alerts to Jira tickets by using a `jiralert` label in alert labels.

An alert may be routed to a Jira ticket by setting the `jiralert` alert label. The value of the label can either be a name of a board in jira, such as `APPSRE`, or a combination of a board and a component, such as `PROJQUAY/quay.io`.

## Implementation

Alerts with a `jiralert` label are matched by a node in the [AlertManager configuration](https://gitlab.cee.redhat.com/service/app-interface/-/blob/209a37d23083ab77dfa7585153b5adf264d17a8a/resources/observability/alertmanager/alertmanager-instance.secret.yaml#L61-86). These matchers are templated based on the existing Jira board files. Additional matchers are added in case an Escalation Policy that references the Jira board also specifies a `jiraComponent`.

Each matcher defines a receiver. Receivers are also templated in the [AlertManager Configuration](https://gitlab.cee.redhat.com/service/app-interface/-/blob/209a37d23083ab77dfa7585153b5adf264d17a8a/resources/observability/alertmanager/alertmanager-instance.secret.yaml#L3760-3795). This configuration includes the authentication information to Jira.

In addition, the Jiralert configuration ([Production](https://gitlab.cee.redhat.com/service/app-interface/-/blob/209a37d23083ab77dfa7585153b5adf264d17a8a/resources/observability/jiralert/jiralert-config.secret.yaml#L65-93), [Stage](https://gitlab.cee.redhat.com/service/app-interface/-/blob/209a37d23083ab77dfa7585153b5adf264d17a8a/resources/observability/jiralert/jiralert-config-stage.secret.yaml#L65-93)) is also templated to include the specification of the receiver. This section will include a configuration for each Jira board. Additional sections are added in case an Escalation Policy that references the Jira board also specifies a `jiraComponent` (such sections will include a `components` stanza).
