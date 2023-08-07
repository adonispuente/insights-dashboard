# netobserv

[TOC]

## Overview

Red Hat offers cluster administrators the Network Observability Operator to observe the network traffic for OpenShift Container Platform clusters.
The Network Observability Operator uses the eBPF technology to create network flows.
The network flows are then enriched with OpenShift Container Platform information and stored in Loki.
You can view and analyze the stored network flows information in the OpenShift Container Platform console for further insight and troubleshooting.

## Install

Installing steps are based on [Installing the Network Observability Operator](https://docs.openshift.com/container-platform/4.13/networking/network_observability/installing-operators.html).

1. Create a S3 bucket for loki, example [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/76006)
1. Install operators
    1. install loki operator, example [file](https://gitlab.cee.redhat.com/service/app-interface/blob/69679c0f7cd91dd6444d9497b034fb092f7c7c40/data/openshift/appsres03ue1/namespaces/openshift-operators-redhat.yaml)
    1. install netobserv operator, example [file](https://gitlab.cee.redhat.com/service/app-interface/blob/d707a5351fc72c29dd5c6a6e14dfab99e9395fff/data/openshift/appsres03ue1/namespaces/openshift-operators.yaml#L25)
1. install LokiStack, example [file](https://gitlab.cee.redhat.com/service/app-interface/blob/600784e9ff6a3a96e50f5c9a4b4ff59dc59f9214/data/services/observability/cicd/saas/saas-loki-for-netobserv.yaml#L64), note LokiStack by default requires at least m5.2xlarge worker instance type
1. install netobserv, example [file](https://gitlab.cee.redhat.com/service/app-interface/blob/600784e9ff6a3a96e50f5c9a4b4ff59dc59f9214/data/services/observability/cicd/saas/saas-netobserv.yaml#L32)

## Usage

1. Login to OpenShift Container Platform console as cluster admin
2. Navigate to Observe -> Network Traffic

Check other usages from [Observing the network traffic](https://docs.openshift.com/container-platform/4.13/networking/network_observability/observing-network-traffic.html)


## Additional Information

- [Check Out the new Network Observability Support in OpenShift 4.12](https://cloud.redhat.com/blog/check-out-the-new-network-observability-support-in-openshift-4.12)
- [netobserv](https://github.com/netobserv)
- [Network Observability Operator release notes](https://docs.openshift.com/container-platform/4.13/networking/network_observability/network-observability-operator-release-notes.html)
