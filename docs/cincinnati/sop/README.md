# SOP : Openshift Cincinnati

<!-- TOC depthTo:2 -->

- [SOP : OpenShift Cincinnati](#sop--openshift-cincinnati)
    - [Verify it's working](#verify-its-working)
    - [Reporting analysis](#reporting-analysis)
    - [GBUpstreamScrapesHalted](#gbupstreamscrapeshalted)
    - [GBUpstreamScrapeErrors](#gbupstreamscrapeerrors)
    - [PEIncomingRequestsHalted](#peincomingrequestshalted)
    - [PEUpstreamErrors](#peupstreamerrors)
    - [PEGraphResponseErrors](#pegraphresponseerrors)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Verify it's working

- At least one `cincinnati` pod is marked as UP in Prometheus.
- Additional details on expected behaviour are available in the Cincinnati production deployment doc: https://docs.google.com/document/d/1oT9wueEB01god-gICg0DsGFJzuA-E-TPn88ViWTMr-A/edit

---

## Reporting analysis

Analysis of alerts should be reported on Slack in `#team-cincinnati-alert`, mentioning both `@app-sre-ic` and `@over-the-air-updates` and.
In cases where that analysis is "this alert is too sensitive; this is nothing we need to worry about in the short term", the mentions are still worthwhile because they make it less likely that either team invests duplicate time in re-analyzing the same alert.

---

## GBUpstreamScrapesHalted

### Summary:

Graph-builder scraping logic is not making progresses.

### Impact:

New releases will not appear in the update graph (the latest cached graph will be kept serving).
Updated releases and transition-edges will not be reflected in the update graph.

### Access required:

- Access to the clusters that run Cincinnati, namespaces:
    - cincinnati-stage (app-sre-stage)
    - cincinnati-production (app-sre)

### Steps:

- Contact Cincinnati team, investigate why graph-builder got blocked.

---

## GBUpstreamScrapeErrors

### Summary:

Graph-builder is failing to scrape release metadata from quay.io.

### Impact:

New releases will not appear in the update graph (the latest cached graph will be kept serving).
Updated releases and transition-edges will not be reflected in the update graph.

### Access required:

- Access to the clusters that run Cincinnati, namespaces:
    - cincinnati-stage (app-sre-stage)
    - cincinnati-production (app-sre)

### Steps:

- Check quay.io outage status: https://status.quay.io/
- Look at the logs for the 'graph-builder' container to pinpoint what is failing.
- If logs contain service errors from quay.io, check #forum-quay-oncall and contact quay.io ops.
- Contact Cincinnati team, investigate why graph-builder is experiencing scapre errors.

---

## PEIncomingRequestsHalted

### Summary:

Policy-engine is not receiving/processing client requests.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) could be hanging or showing errors on clusters console.

### Access required:

- Access to the clusters that run Cincinnati, namespaces:
    - cincinnati-stage (app-sre-stage)
    - cincinnati-production (app-sre)

### Steps:

- Investigate pod connectivity.
- Contact Cincinnati team, investigate why policy-engine is not processing client requests.

---

## PEUpstreamErrors

### Summary:

Policy-engine is working and processing client request, but its upstream graph-builder is returning errors.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) is showing errors on clusters console.

### Access required:

- Access to the clusters that run Cincinnati, namespaces:
    - cincinnati-stage (app-sre-stage)
    - cincinnati-production (app-sre)

### Steps:

- Contact Cincinnati team, investigate why policy-engine is not processing client requests.

---

## PEGraphResponseErrors

### Summary:

Policy-engine is working and processing client requests, but many of them result in errors.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) is showing errors on clusters console.

### Access required:

- Access to the clusters that run Cincinnati, namespaces:
    - cincinnati-stage (app-sre-stage)
    - cincinnati-production (app-sre)

### Steps:

- Contact Cincinnati team, investigate why policy-engine is generating error-reponses.

---

## Escalations

Slack: `#forum-auto-updates`

Developers: `@over-the-air-updates`

Slack alerts: `#team-cincinnati-alert`

Team email: aos-team-ota@redhat.com
