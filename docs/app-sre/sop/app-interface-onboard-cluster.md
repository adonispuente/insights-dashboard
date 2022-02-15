<!-- TOC -->

- [Onboard a new OSDv4 cluster to app-interface](#onboard-a-new-osdv4-cluster-to-app-interface)
  - [Step 1 - Cluster creation and initial access for dedicated-admins](#step-1---cluster-creation-and-initial-access-for-dedicated-admins)
  - [Step 2 - Bot access and App SRE project template](#step-2---bot-access-and-app-sre-project-template)
  - [Step 3 - Observability](#step-3---observability)
  - [Step 4 - Operator Lifecycle Manager](#step-4---operator-lifecycle-manager)
  - [Step 5 - Container Security Operator](#step-5---container-security-operator)
  - [Step 6 - Deployment Validation Operator (DVO)](#step-6---deployment-validation-operator-dvo)
  - [Step 7 - Obtain cluster-admin](#step-7---obtain-cluster-admin)
- [Additional configurations](#additional-configurations)
  - [Selecting a Machine CIDR for VPC peerings](#selecting-a-machine-cidr-for-vpc-peerings)
  - [VPC peering with app-interface](#vpc-peering-with-app-interface)
  - [Additional steps for clusters for specific services](#additional-steps-for-clusters-for-specific-services)
- [Offboard an OSDv4 cluster from app-interface](#offboard-an-osdv4-cluster-from-app-interface)
- [Legacy (v3)](#legacy-v3)
  - [Onboard a new OSDv3 cluster to app-interface](#onboard-a-new-osdv3-cluster-to-app-interface)

<!-- /TOC -->

# Onboard a new OSDv4 cluster to app-interface

To on-board a new OSDv4 cluster to app-interface, perform the following operations:

## Step 1 - Cluster creation and initial access for dedicated-admins

This step should be performed in a single merge request.

1. Login to https://console.redhat.com/openshift

1. Click `Subscriptions` and ensure you have enough quota to provision a cluster
    - Must have at least 1 cluster of the desired type
    - Check that you have enough compute nodes quota for the desired total compute (4 are included in a single-az cluster, 9 in a multi-az)
    - Note that quota is driven via this [repo](https://gitlab.cee.redhat.com/service/ocm-resources/) and this is our [org file](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-production/orgs/12147054.yaml) in prod. The `@ocm-resources` Slack alias can also be pinged for any questions or if the change is urgent.
    - Use the [OCM resource cost mappings spreadsheet](https://docs.google.com/spreadsheets/d/1HGvQnahZCxb_zYH2kSnnTFsxy9MM49vywd-P0X_ISLA/edit#gid=315221665) mapping table to find which are correspondences between OCM types and AWS instance types

1. Create a new App-SRE Github Oauth Client.
    In order to create the OAuth client register to create a new application here:
    https://github.com/organizations/app-sre/settings/applications

    - Name: `<cluster_name> cluster`
    - Homepage URL: `https://console-openshift-console.apps.<cluster_name>.TBD.p1.openshiftapps.com`
    - Authorization callback URL: `https://oauth-openshift.apps.<cluster_name>.TBD.p1.openshiftapps.com/oauth2callback/github-app-sre`

1. Place the `client-id` and `client-secret` from the Oauth Client in a secret in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/integrations-input/ocm-github-idp/github-org-team/app-sre/) named `<cluster_name>-cluster`.

1. Cluster creation in OCM is self-serviced in app-interface. As such cluster.yml file should be added to app-interface at this point

    ```yaml
    # /data/openshift/<cluster_name>/cluster.yml
    ---
    $schema: /openshift/cluster-1.yml

    labels:
      service: <service>

    name: <cluster_name>
    description: <cluster_name> cluster
    consoleUrl: ''
    kibanaUrl: ''
    prometheusUrl: ''
    alertmanagerUrl: ''
    serverUrl: ''
    elbFQDN: ''

    auth:
      service: github-org-team
      org: app-sre
      team: <cluster_name>-cluster

    ocm:
      $ref: /dependencies/ocm/production.yml

    managedGroups:
    - dedicated-admins

    spec:
      provider: aws
      region: (desired region. ex: us-east-1)
      channel: (desired channel group. either 'stable' or 'fast', use the latest 'fast' version by default, unless the cluster hosts OSD related workloads. latest fast can be found in https://gitlab.cee.redhat.com/service/clusterimagesets/-/tree/master/prod)
      version: (same as initial_version, this will be automatically updated with cluster upgrades)
      initial_version: (desired version. ex: 4.4.11)
      multi_az: true
      nodes: (desired compute nodes todal across all AZs)
      autoscale: # optional. nodes should not be defined if autoscale is defined
        min_replicas: (desired minimal count of compute nodes todal across all AZs)
        max_replicas: (desired maximal count of compute nodes todal across all AZs)
      instance_type: (desired instance type. ex: m5.xlarge)
      storage: (desired storage amount. ex: 600)
      load_balancers: (desired load-balancer count. ex: 0)
      private: false (or true for private clusters)
      provision_shard_id: (optional) specify hive shard ID to create the cluster in (IDs can be found in the uhc-production namespace file)
      disable_user_workload_monitoring: true

    upgradePolicy: # optional, specify an upgrade schedule
      workloads: [] # workloads running in this cluster
      schedule: '0 10 * * 4' # choose a cron expression to upgrade on
      conditions:
        soakDays: N # number of days a version should run on other clusters with similar workloads before this cluster is upgraded to it

    network:
      # For OVN, use OVNKUbernetes
      type: OpenshiftSDN
      vpc: (desired machine CIDR. ex: 10.123.0.0/16)
      service: (desired service CIDR. ex: 172.30.0.0/16)
      pod: (desired pod CIDR. ex: 10.128.0.0/14)

    automationToken:
      path: app-sre/creds/kube-configs/<cluster_name>
      field: token

    machinePools: # optional, specify additional Machine Pools to be provisioned
    - id: (machine pool name, should be unique per cluster)
      instance_type: (desired instance type. m5.xlarge for example)
      replicas: (desired number of instances in the pool)
      labels: {}

    addons: # enable log forwarding to the cluster's AWS account
    - $ref: /dependencies/ocm/addons/cluster-logging-operator.yml

    internal: false

    awsInfrastructureAccess:
    - awsGroup:
        $ref: /aws/<aws account name>/groups/App-SRE-admin.yml
      accessLevel: read-only
    - awsGroup:
        $ref: /aws/<aws account name>/groups/App-SRE-admin.yml
      accessLevel: network-mgmt

    awsInfrastructureManagementAccounts:
    - account:
        $ref: /aws/<aws account name>/account.yml
      accessLevel: network-mgmt
      default: true
    ```

    * Note: Cluster name should follow naming convention
      [here](https://docs.google.com/document/d/1OIe4JGbScz57dIGZztThLTvji056OBCfaHSvGAo7Hao)
    * Note: The `id`, `consoleUrl`, `serverUrl`, `external_id` and `elbFQDN` will be added automatically at a later stage. Don't worry about them.

1. Grant `dedicated-admin` access to App-SRE team

    ```yaml
    # /data/teams/app-sre/roles/app-sre.yml
    ...
    access:
        ...
        - cluster:
            $ref: /openshift/<cluster_name>/cluster.yml
        group: dedicated-admins
    ```

1. Send the MR, wait for the check to pass and merge. The ocm-clusters integration will create your cluster. You can view the progress in OCM. Proceed with the following steps after the cluster's installation is complete.

    * Note: during the installation it is expected that other ocm integrations will fail.

1. Once the cluster has finished installing, the following fields will be updated automatically in the `cluster.yml` file in the:
    * `consoleUrl`
    * `serverUrl`
    * `kibanaUrl`
    * `elbFQDN`
    * `id` (in the `spec` section)
    * `external_id` (in the `spec` section)
1. Now, you can add these URLs manually (we'll automate this step in the future):
    * `alertmanagerUrl`: `https://alertmanager.<cluster_name>.devshift.net`
    * `prometheusUrl`: `https://prometheus.<cluster_name>.devshift.net`

    *Note*: The `<cluster_name>` and `<base_domain>` of a cluster can be retrieved using the [ocm cli](https://github.com/openshift-online/ocm-cli)

    ```shell
    ocm list clusters

    ID=<ID>
    ocm get cluster $ID | jq . '.name'
    ocm get cluster $ID | jq . '.dns.base_domain'

    # One-liner to get the complete DNS name of a cluster
    ocm get cluster $ID | jq -r '(.name + "." + .dns.base_domain)'
    ```

    *Note*: The cluster's spec.id and spec.external_id can be obtained using the following commands:

    ```shell
    $ ocm get cluster <ID> | jq . '.id'
    $ ocm get cluster <ID> | jq . '.external_id'
    ```

    These values will be added automatically by the `ocm_clusters` integration.

1. Update App-SRE Github Oauth Client.
    - Homepage URL: `https://console-openshift-console.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com/`
        * Note: cluster_id can be obtained from the console.  In OCM, click on the link for the cluster and then click on the `Open Console` button in the upper right corner.  Looking at the URL bar there should be something like: `oauth-openshift.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com`
    - Authorization callback URL: `https://oauth-openshift.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com/oauth2callback/github-app-sre`


1. If your cluster is private, you should first make sure you can access it through ci.ext via VPC peering.

    1. Configure VPC peering to jumphost (ci.ext) as needed for private clusters. See  [app-interface-cluster-vpc-peerings.md](app-interface-cluster-vpc-peerings.md).

        ```yaml
        peering:
          connections:
          - provider: account-vpc
            name: <cluster_name>_app-sre
            vpc:
              $ref: /aws/app-sre/vpcs/app-sre-vpc-02-ci-ext.yml
            manageRoutes: true
        ```
    1. Once the above is merged and deployed, you should add a route in app-sre vpc. This is achieved in [app-sre/infra](https://gitlab.cee.redhat.com/app-sre/infra) repo. See this [MR](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/79) as an example. You can get VPC peering connection name from the app-sre AWS account.

## Step 2 - Bot access and App SRE project template

At this point you should be able to access the cluster via the console / `oc` cli.

* Note: This step should be performed in a single merge request.

1. Add the `app-sre-bot` ServiceAccount

    ```shell
    oc -n dedicated-admin create sa app-sre-bot
    oc -n dedicated-admin sa get-token app-sre-bot
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
          hostname: bastion.ci.ext.devshift.net
          knownHosts: /jump-host/known-hosts/bastion.ci.ext.devshift.net
          user: app-sre-bot
          identity:
            path: app-sre/ansible/roles/app-sre-bot
            field: identity
            format: base64
        ```

    1. Request vpc peering config to `app-sre-prod-01` to your `cluster.yml` file:

        ```yaml
        - provider: cluster-vpc-requester
          name: <cluster_name>_app-sre-prod-01
          cluster:
            $ref: /openshift/app-sre-prod-01/cluster.yml
          manageRoutes: true
        ```

    1. Accepter vpc peering config `app-sre-prod-01`'s `cluster.yml` file:

        ```yaml
        - provider: cluster-vpc-accepter
          name: app-sre-prod-01_<cluster_name>
          cluster:
            $ref: /openshift/<cluster_id>/cluster.yml
          manageRoutes: true
        ```

1. Add the `openshift-config` namespace in app-interface.  This adds the project request template to the cluster

    ```yaml
    # /data/openshift/<cluster_name>/namespaces/openshift-config.yml
    ---
    $schema: /openshift/namespace-1.yml

    labels: {}

    name: openshift-config
    description: <cluster_name> openshift-config namespace

    cluster:
      $ref: /openshift/<cluster_name>/cluster.yml

    app:
      $ref: /services/app-sre/app.yml

    environment:
      $ref: /products/app-sre/environments/<integration/stage/production>.yml

    managedResourceTypes:
    - Template
    - Project
    - ClusterRoleBinding

    # when using `oc`, use the override as the kind instead of the resource
    managedResourceTypeOverrides:
    - resource: Project
      override: Project.config.openshift.io

    managedResourceNames:
    # https://github.com/openshift/managed-cluster-config/blob/master/deploy/osd-project-request-template/02-role.dedicated-admins-project-request.yaml#L12
    - resource: Template
      resourceNames:
        - project-request
    - resource: Project
      resourceNames:
        - cluster

    openshiftResources:
    - provider: resource
      path: /setup/project-request.v4.template.yaml
    # these are cluster scoped resources, but this should work for now
    - provider: resource
      path: /setup/cluster.project.v4.yaml
    - provider: resource
      path: /setup/self-provisioners.clusterrolebinding.yaml
    - provider: resource
      path: /setup/dedicated-readers.clusterrolebinding.yaml
    ```

1. Send the MR, wait for the check to pass and merge.

## Step 3 - Observability
1. Add Prometheus/Alertmanager DNS records to the [devshift.net DNS zone file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/devshift.net.yaml)
    ```bash
    hack/cluster_provision.py create-obs-dns-records <cluster>
    ```

2. Enable `openshift-customer-monitoring`:
    As of OpenShift 4.6.17, UWM (user-workload-monitoring) is enabled by default on OSD, replacing `openshift-customer-monitoring`. App-SRE still uses `openshift-customer-monitoring` and as such we need to disable UWM for us so we can use the current monitoring configs as described below. This is done through the OCM console (Settings -> uncheck "Enable user workload monitoring" -> Save).

    **`user-workload-monitoring` is disabled automatically by ocm_clusters integration. If you created the cluster through app-interface it should be already disabled**

    To enable `openshift-customer-monitoring` just run this command:
    ```bash
    hack/cluster_provision.py create-obs-customer-monitoring <cluster> <environment>
    ```
    This command does the following steps:
    * Creates the `openshift-customer-monitoring` namespace with this [template](https://gitlab.cee.redhat.com/service/app-interface/blob/master/hack/cluster_provision/templates/openshift-customer-monitoring.CLUSTERNAME.tpl). View an example [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml)
    * Adds the new `openshift-customer-monitoring` namespace to the target namespaces in [saas-observability-per-cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml) to deploy Prometheus and Alertmanager.
    * Adds the `cluster-monitoring-view` ClusterRole to the cluster [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-clusters-view.yml)
    * Adds `managedClusterRoles: true` to `cluster.yml` file
    * Adds the `observabilityNamespace` field on the cluster.yml file and reference the `openshift-customer-monitoring` namespace: [Example](https://gitlab.cee.redhat.com/service/app-interface/blob/7ecd529584666d97b1418224b2772557807c6e1c/data/openshift/app-sre-prod-01/cluster.yml#L14-15)
    * Creates an `app-sre-observability-per-cluster` namespace file for that specific cluster. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/app-sre-prod-01/namespaces/app-sre-observability-per-cluster.yml)
    * Adds the new `app-sre-observability-per-cluster` namespace to list of namespaces in [observability-access-elevated.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/observability-access-elevated.yml) under `access`, to allow users with elevated observability access to access all the prometheus.
    * Adds the new `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-nginx-proxy.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-nginx-proxy.yaml) to deploy nginx-proxy.
    * If the cluster is not private, it adds the `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-openshift-acme.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/saas-openshift-acme.yaml) to deploy openshift-acme.
        * Note: A private cluster can not use openshift-acme since it is not exposed to the public internet. Routes should still work, but the certificate will be invalid.

3. Add the new grafana datasources for the new cluster:
  [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/667dde06bb4c2b27656791ca05d5b7ba47b9d432/resources/observability/grafana/grafana-datasources.secret.yaml#L13-42)
  You can do that with this command:
  ```bash
  hack/cluster_provision.py create-obs-grafana-datasources <cluster>
  ```
  **Double check the changes introduced, the destination file could have been modified with manual changes**

4. Configure a [deadmanssnitch](https://deadmanssnitch.com/) snitch for the new cluster. The snitch settings should be as follow:
    - Name: prometheus.<cluster_name>.devshift.net
    - Alert type: Basic
    - Interval: 15 min
    - Tags: app-sre
    - Alert email: sd-app-sre@redhat.com
    - Notes: Runbook: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/prometheus/prometheus-deadmanssnitch.md

5. Add the deadmanssnitch URL to this secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-input/alertmanager-integration
    - key: `deadmanssnitch-<cluster_name>-url`
    - value: the `Unique Snitch URL` from deadmanssnitch

6. **IMPORTANT**: Merge the changes and check that the integrations have ran successfully. Check that `https://<prometheus|alertmanager>.<cluster_name>.devshift.net` have valid ssl certificates by accessing the URLs. If no security warning is given and the connection is secure as notified by the browser.

## Step 4 - Operator Lifecycle Manager

1. Install the Operator Lifecycle Manager

    The Operator Lifecycle Manager is responsible for managing operator lifecycles.  It will install and update operators using a subscription.

    1. Create an `openshift-operator-lifecycle-manager.yml` namespace file for the cluster with this command:

    ```bash
    hack/cluster_provision.py [--datadir=data directory] create-olm-ns <cluster-name>
    ```

## Step 5 - Container Security Operator

The Container Security Operator (CSO) brings Quay and Clair metadata to
Kubernetes / OpenShift. We use the vulnerabilities information in the tenants
dashboard and in the monthly reports.

To create the CSO operator configs, run the following command:

```bash
hack/cluster_provision.py [--datadir=data directory] create-cso-cluster-config <cluster-name>
```

## Step 6 - Deployment Validation Operator (DVO)

The Deployment Validation Operator inspects workloads in a cluster and evaluates them against know best practices.  It generates metric information about which workloads in which namespaces do not meet specific guidelines.  This information is presented in tenant dashboards and in monthly reports.

To create the DVO operator configs, run the following command:

```bash
hack/cluster_provision.py [--datadir=data directory] create-dvo-cluster-config <cluster-name>
```

## Step 7 - Obtain cluster-admin

1. Create an OHSS ticket to enable cluster-admin in the cluster. Examples: [OHSS-5302](https://issues.redhat.com/browse/OHSS-5302), [OHSS-5939](https://issues.redhat.com/browse/OHSS-5939)

1. Once the ticket is Done, add yourself (temporarily) to the cluster-admin group via OCM: https://docs.openshift.com/dedicated/administering_a_cluster/osd-admin-roles.html

1. Login to the cluster, create a cluster-admin ServiceAccount, grant it the cluster-admin role and obtain its token:
  ```sh
  $ oc new-project app-sre
  $ oc -n app-sre create sa app-sre-cluster-admin-bot
  $ oc adm policy add-cluster-role-to-user cluster-admin -z app-sre-cluster-admin-bot
  $ oc -n app-sre sa get-token app-sre-cluster-admin-bot
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

1. Remove yourself from the cluster-admin group via OCM.

# Additional configurations

## Selecting a Machine CIDR for VPC peerings

If your cluster need to be peered with other clusters or AWS VPCs, it is required that the Machine CIDR is set to one that does not conflict with the other resources. This the case for most of the AppSRE clusters. In order to be able to select this you must used `Advanced` network definition option.

App-interface has network information for all v4 clusters it is managing. Thus, running a simple query in app-interface can help retrieve known CIDR and make a decision on which CIDR to use for the new clusters

```
{clusters_v1{name network{vpc service pod}}}
```

There is a convenience utility to fetch this data: `qontract-cli get clusters-network`.

The value of the NETWORK.VPC must be unique (find an unused /24 network), however, the NETWORK.SERVICE and NETWORK.POD can be reused (`10.120.0.0/16` and `10.128.0.0/14` respectively).

Note that the host prefix must be set to /23.

## VPC peering with app-interface

[app-interface-cluster-vpc-peerings.md](app-interface-cluster-vpc-peerings.md)

## Additional steps for clusters for specific services

1. If the cluster is a hive shard, follow the [Hive shard provisioning SOP](/docs/app-sre/sop/hive-shard-provisioning.md)
1. If the cluster is a console.redhat.com (crc) cluster, perform the following steps:
  * Deploy [3rd party operators](/data/services/insights/third-party-operators) (includes AMQ streams operator)
  * Deploy [Clowder operator](/data/services/insights/clowder)

# Offboard an OSDv4 cluster from app-interface

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


# Legacy (v3)

## Onboard a new OSDv3 cluster to app-interface

To on-board a new OSDv3 cluster to app-interface, perform the following operations:

1. Create `app-sre-bot` ServiceAccount in the `dedicated-admin` namespace and add permissions to the ServiceAccount:

```shell
oc -n dedicated-admin create serviceaccount app-sre-bot
```

2. Get the token of the `app-sre-bot` SeriveAccount:

```shell
oc -n dedicated-admin sa get-token app-sre-bot
```

3. Create a secret in Vault under the following path: `app-sre/creds/kube-configs/<cluster_name>`.
    * The secret should have a `token` key with the value being the token from step 2.
    * The secret should have a `server` key with the server URL. For example: `https://api.app-sre.openshift.com:443`.
    * The secret should have a `username` key with this text: `dedicated-admin/app-sre-bot # not used by automation`.
