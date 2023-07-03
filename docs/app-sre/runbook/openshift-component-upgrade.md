# OpenShift Component Upgrade

[TOC]

## Overview

When openshift cluster version upgrade, some components need to be upgraded as well.
This document describes the process of upgrading these components.

## OpenShift Pipelines

1. Check release notes for the new version of OpenShift Pipelines, [example](https://docs.openshift.com/container-platform/4.13/cicd/pipelines/op-release-notes.html)
1. Update channels mapping in [openshift-pipelines-operator-rh.subscription.j2](/resources/tekton/openshift-pipelines-operator-rh.subscription.j2)

## cert-manager Operator

1. Check release notes for the new version of cert-manager operator, [example](https://docs.openshift.com/container-platform/4.13/security/cert_manager_operator/cert-manager-operator-release-notes.html)
1. Update channels mapping in [openshift-cert-manager-operator.subscription.j2](/resources/cert-manager/openshift-cert-manager-operator.subscription.j2)

## Event Router

1. Check image version used in doc, [example](https://docs.openshift.com/container-platform/4.13/logging/cluster-logging-eventrouter.html)
1. Sync version in [event-router.template.yaml](https://gitlab.cee.redhat.com/service/app-sre-observability/-/blob/6c6ff6f7f1485b6665eca42d5555dc2a606e658f/openshift/event-router.template.yaml#L94)
1. Update ref in [saas-event-router.yaml](/data/services/observability/cicd/saas/saas-event-router.yaml)
