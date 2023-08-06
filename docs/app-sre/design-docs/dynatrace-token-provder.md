# Design Document - Dynatrace Log Ingestion

[toc]

## Author / Date

App SRE / Aug 2023

## Tracking JIRA

[SDE-3300](https://issues.redhat.com/browse/SDE-3300)

## Problem statement

We need a safe and repeatable mechanism for some clusters (specific type of clusters mentioned below) get the Dynatrace token they need to send metrics, logs etc to the corresponding Dynatrace environment(also called tenant).

## Goals

* Hypershift hive managed management clusters and service clusters can get dedicated Dynatrace token for the corresponding Dynatrace environment.

## Non-Goals

* Integrate all existing Dynatrace environments into App Interface
* Any clusters that's out of the cases mentioned above.
* Who and how the labels are going to be added to the clusters (osd-fleet-manager ideally should be responsible of it).
* Token recycle. This should be defer to the cloud platform that issue the token, which is Dynatrace in this case. 

## Proposals
![](images/dynatrace-token-provider.png)

We use a qontract-reconcile integration called dynatrace-token-provider to achieve following workflow:

1. The cluster owner will use [the subscription or organizations label](https://service.pages.redhat.com/dev-guidelines/docs/sre-capabilities/framework/ocm-labels/) for SRE capabilities to identify the clusters that is eligible. The label will contain the information of which Dynatrace environment it needs access to(tenant ID). 
2. Then our integration to discover those clusters through OCM API. (We do similar things in rhidp integration [here](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/rhidp/common.py#L42))
3. The integration will then create an access token for that cluster by calling [Dynatrace API](https://www.dynatrace.com/support/help/dynatrace-api/environment-api/tokens-v2/api-tokens/post-token) using a bootstrap token. 
    * The bootstrap token will be created manually for all the Dynatrace environments and saved to vault for now (There are currently eight Dynatrace environments and four of them are has bootstrap token saved in vault [here](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/dynatrace/redhat-aws/bootstrap-api-tokens/) during the dynatrace-config repo tenant bootstrapping).
4.dynatrace-token-provider calls [SyncSet API](https://api.openshift.com/#/default/post_api_clusters_mgmt_v1_clusters__cluster_id__external_configuration_syncsets) to create the Secret with the token in `dynatrace` namespace.

To avoid unexpected use cases, when clusters are retrieved from OCM API, the organizations that they belong to will need to be allowed by cross referencing App Interface. We also want to make sure that when the integration failed due to user error, App SRE are not responding as we are to regular integration, i.e. there will be no pager created for this integration.

Under the situation when tokens are leaked, user need to go to Dynatrace to revoke and delete token. Then the integration will create another token with the same name and overwrite the old token with the new one.

## Alternative considered

There were a lot of discussion around doing this in other places such as [ocm-sendgrid-service](https://gitlab.cee.redhat.com/service/ocm-sendgrid-service) or osd-fleet-manager. However those approaches will depend on other team's availability, meanwhile there were some concerns raised around the current design of [distributing tokens](https://docs.google.com/document/d/1rAPTtEXCz7KQAbXruEkbkkZLa2rHJSlyTAVtnv1GeO4/edit#heading=h.lx1q59w5wz3o) with a upcoming Aug 18th Dynatrace Milestone 2 timeline.


## Milestones
1. Bootstrap token created, and new integration merged, tested in one cluster
2. dynatrace-toke-provider deploys tokens to management and services clusters (This will be a joined effort among SREs working on Dynatrace)