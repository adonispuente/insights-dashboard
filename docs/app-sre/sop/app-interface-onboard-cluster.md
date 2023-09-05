# Onboard a new cluster to app-interface

[TOC]

## Selecting a Machine CIDR for VPC peerings

If your cluster need to be peered with other clusters or AWS VPCs, and as a general good practice, it is required that the Machine CIDR is set to one that does not conflict with the other resources. This the case for most of the AppSRE clusters. In order to be able to select this you must used `Advanced` network definition option.

App-interface has network information for all v4 clusters it is managing. Thus, running a simple query in app-interface can help retrieve known CIDR and make a decision on which CIDR to use for the new clusters

```
{clusters_v1{name network{vpc service pod}}}
```

There is a convenience utility to fetch this data: `qontract-cli get clusters-network`.

The value of the NETWORK.VPC must be unique (find an unused /24 network), however, the NETWORK.SERVICE and NETWORK.POD can be reused (`10.120.0.0/16` and `10.128.0.0/14` respectively).

**DO NOT USE anything within 10.30.0.0/16** as this is used by Red Hat IT's internal resources on AWS (which will cause conflicts if the cluster is peered with ci-int)

Note that the host prefix must be set to /23.

## Create the cluster

Note: Cluster name should follow naming convention [here](../cluster-naming-convention.md)

The cluster creation process varies a bit depending on the cluster type.

- [OSD non-CCS](/docs/app-sre/runbook/openshift-osd-clusters.md)
- [Rosa Public](/docs/app-sre/runbook/openshift-rosa-clusters.md#create-a-new-rosa-public-cluster)
- [Rosa STS/Privatelink](/docs/app-sre/runbook/openshift-rosa-clusters.md#create-a-new-rosa-sts-privatelink-cluster)
- [Hypershift Hosted Cluster](/docs/app-sre/runbook/openshift-rosa-clusters.md#create-a-new-hypershift-cluster)


## App-interface setup
Right now, you should have a cluster.yml file in app-interface.

1. Ensure the `redhat-app-sre-auth` OIDC provider in cluster.yml is setup
    ```yaml
    auth:
    - service: oidc
      name: redhat-app-sre-auth

    ocmSubscriptionLabels:
      sre-capabilities:
        rhidp:
          status: enabled
          name: redhat-app-sre-auth
    ```

2. Grant `dedicated-admin` access to App-SRE team

    ```yaml
    # /data/teams/app-sre/roles/app-sre.yml
    ...
    access:
        ...
        - cluster:
            $ref: /openshift/<cluster_name>/cluster.yml
        group: dedicated-admins
    ```

3. Grant the AppSRE gitlab bot (@devtools-bot) permissions to self-service updates to the cluster file:

    ```yaml
    # /data/teams/app-sre/roles/app-sre-gitlab-bot.yml
    ...
    self_service:
    - change_type:
        $ref: /app-interface/changetype/cluster-auto-updater.yml
      datafiles:
      ...
      - $ref: /openshift/<cluster_name>/cluster.yml
    ```

Merge this.

At this point you should be able to access the cluster via the console / `oc` cli.

* Note: This step should be performed in a single merge request.

1. Add the `app-sre-bot` ServiceAccount

    ```shell
    $ oc -n dedicated-admin create sa app-sre-bot
    
    $ echo "apiVersion: v1
    kind: Secret
    metadata:
      annotations:
        kubernetes.io/service-account.name: app-sre-bot
      name: app-sre-bot
      namespace: dedicated-admin
    type: kubernetes.io/service-account-token" | oc create -f -

    $ oc get secret -n dedicated-admin app-sre-bot -o jsonpath={.data.token} | base64 --decode
    ```

1. Add the `app-sre-bot` credentials to [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs). qontract-reconcile integrations errors indicating that the token wasn't found will clear once the credentials are in the vault.

   Create a secret named after the <cluster_name>

       server: https://api.<cluster_name>.<cluster_id>.p1.openshiftapps.com:6443
       token: <token>
       username: dedicated-admin/app-sre-bot # not used by automation

1. If the cluster is private, the following lines must be added

    1. Jump host configuration to your `cluster.yml` file:
        ```yaml
        jumpHost:
          $ref: /openshift/bastion.ci.int.devshift.net.jumphost.yml
        ```

    1. Request vpc peering config to `appsrep05` to your `cluster.yml` file:

        ```yaml
        - provider: cluster-vpc-requester
          name: <cluster_name>_appsrep05ue1
          cluster:
            $ref: /openshift/appsrep05ue1/cluster.yml
          manageRoutes: true
        ```

    1. Accepter vpc peering config `appsrep05ue1`'s `cluster.yml` file:

        ```yaml
        - provider: cluster-vpc-accepter
          name: appsrep05ue1_<cluster_name>
          cluster:
            $ref: /openshift/<cluster_id>/cluster.yml
          manageRoutes: true
        ```

1. Add yourself (temporarily) to the cluster-admin group via OCM: https://docs.openshift.com/dedicated/administering_a_cluster/osd-admin-roles.html

1. Login to the cluster, create a cluster-admin ServiceAccount, grant it the cluster-admin role and obtain its token:
  ```sh
  $ oc new-project app-sre
  
  $ oc -n app-sre create sa app-sre-cluster-admin-bot
  
  $ oc adm policy add-cluster-role-to-user cluster-admin -z app-sre-cluster-admin-bot
  
  $ echo "apiVersion: v1
  kind: Secret
  metadata:
    annotations:
      kubernetes.io/service-account.name: app-sre-cluster-admin-bot
    name: app-sre-cluster-admin-bot
  type: kubernetes.io/service-account-token" | oc create -f - -n app-sre

  $ oc get secret -n app-sre app-sre-cluster-admin-bot -o jsonpath={.data.token} | base64 --decode
  ```

1. Add the `app-sre-cluster-admin-bot` credentials to vault at https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs

   Create a secret named after the <cluster_name>-cluster-admin:
       server: https://api.<cluster_name>.<cluster_id>.p1.openshiftapps.com:6443
       token: <token>
       username: app-sre/app-sre-cluster-admin-bot # not used by automation

1. Add the `app-sre-cluster-admin-bot` credentials to the cluster file in app-interface

    ```yaml
    # /data/openshift/<cluster_name>/cluster.yml
    clusterAdminAutomationToken:
      path: app-sre/creds/kube-configs/<cluster_name>-cluster-admin
      field: token
    ```

1. Remove yourself from the cluster-admin group via OCM.

1. Send the MR, wait for the check to pass and merge.


## Dress up the cluster

Once the cluster exists in app-interface and can be targeted, we can dress it up to match AppSRE tooling and processes. This is described in the [cluster dress-up](/docs/app-sre/runbook/app-interface-dressup-cluster.md) runbook.


# Offboard a cluster from app-interface

To off-board an OSDv4 cluster from app-interface, perform the following operations:

1. Verify that the cluster is no longer in use and create a MR to remove it from app-interface.
  - Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/5793
  - Things to look out for:
    - openshift-customer-monitoring namespace does not contain any tenant monitoring resources
    - if the cluster has existing VPC peerings, configure them to be deleted in a separate MR first by adding `delete: true` to each peering connection:

        ```yaml
        peering:
          connections:
          - provider: account-vpc
            name: <name>
            vpc:
              $ref: <ref>
            delete: true
        ```

      Once that MR has merged, run the `terraform-vpc-peerings` integration with `--enable-deletion` to remove the peering connections.  Once the peering connections are removed it is safe to delete the cluster.

      *NOTE*: How to run an integration is documented [here](https://github.com/app-sre/qontract-reconcile#usage)

1. Merge the merge request before proceeding.

1. Delete the cluster from the Dead Man's Snitch console: https://deadmanssnitch.com/cases/0693dfc1-40e9-4e84-89b2-30d696e77e06/snitches?tags=app-sre

1. Delete the cluster from the OCM console: https://console.redhat.com/openshift

1. Delete the cluster credentials from Vault (verify that no secrets are in use):
  - https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/
  - https://vault.devshift.net/ui/vault/secrets/app-interface/list/<cluster_name>/
  - https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-input/alertmanager-integration
  - https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources
