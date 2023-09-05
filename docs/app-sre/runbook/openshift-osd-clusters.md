# Create a new OSD cluster in app-interface

This guide describes how to create an OSD cluster in app-interface. The process is fully automated but requires multiple Merge Requests.

[TOC]

## OSD Cluster creation and initial access for dedicated-admins and automatic cluster file updates

This step should be performed in a single merge request.

1. Login to https://console.redhat.com/openshift with your APPSRE admin account (e.g. <kerberos_id>+sd-app-sre@redhat.com)

1. Click `Subscriptions` and ensure you have enough quota to provision a cluster
    - Must have at least 1 cluster of the desired type
    - Check that you have enough compute nodes quota for the desired total compute (4 are included in a single-az cluster, 9 in a multi-az)
    - Note that quota is driven via this [repo](https://gitlab.cee.redhat.com/service/ocm-resources/) and this is our [org file](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-production/orgs/12147054.yaml) in prod. The `@ocm-resources` Slack alias can also be pinged for any questions or if the change is urgent.
    - Use the [OCM resource cost mappings spreadsheet](https://docs.google.com/spreadsheets/d/1HGvQnahZCxb_zYH2kSnnTFsxy9MM49vywd-P0X_ISLA/edit#gid=315221665) mapping table to find which are correspondences between OCM types and AWS instance types

1. Cluster creation in OCM is self-serviced in app-interface. As such `cluster.yml` file should be added to app-interface at this point

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
    - service: oidc
      name: redhat-app-sre-auth

    ocmSubscriptionLabels:
      sre-capabilities:
        rhidp:
          status: enabled
          name: redhat-app-sre-auth

    ocm:
      $ref: /dependencies/ocm/production.yml

    managedGroups:
    - dedicated-admins

    spec:
      product: osd
      provider: aws
      region: (desired region. ex: us-east-1)
      channel: (desired channel group. either 'stable' or 'fast', use the latest 'fast' version by default, unless the cluster hosts OSD related workloads. latest fast can be found in https://gitlab.cee.redhat.com/service/clusterimagesets/-/tree/master/prod)
      version: (same as initial_version, this will be automatically updated with cluster upgrades. However remove suffix -fast if applicable.)
      initial_version: (desired version. ex: 4.4.11, use 4.4.11-fast if channel fast.)
      multi_az: true
      nodes: (desired compute nodes total across all AZs) # do not set for hypershift
      autoscale: # optional. do not set for hypershift, nodes should not be defined if autoscale is defined
        min_replicas: (desired minimal count of compute nodes total across all AZs)
        max_replicas: (desired maximal count of compute nodes total across all AZs)
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

    network: # cidr list for each cluster can be found here: https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/clusters-network.md
      # For openshift-sdn, use OpenShiftSDN
      type: OVNKubernetes
      vpc: (desired machine CIDR. ex: 10.123.0.0/16)
      service: (desired service CIDR. ex: 172.30.0.0/16)
      pod: (desired pod CIDR. ex: 10.128.0.0/14)

    automationToken:
      path: app-sre/creds/kube-configs/<cluster_name>
      field: token

    clusterAdmin: true # should enable cluster admin for this cluster via OCM

    machinePools: # optional, specify additional Machine Pools to be provisioned
    - id: (machine pool name, should be unique per cluster)
      instance_type: (desired instance type. m5.xlarge for example)
      replicas: (desired number of instances in the pool)
      labels: {}

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
      [here](../cluster-naming-convention.md)
    * Note: The `id`, `consoleUrl`, `serverUrl`, `external_id` and `elbFQDN` will be added automatically at a later stage. Don't worry about them.
    * Note: Network - https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/clusters-network.md
      * vpc: Define a new one (e.g. 10.X.0.0/16) that isn't already in use
        * **DO NOT USE anything within 10.30.0.0/16** as this is used by Red Hat IT's internal resources on AWS (which will cause conflicts if the cluster is peered with ci-int)
      * service: 172.30.0.0/16 can be used
      * pod: 10.128.0.0/14 can be used

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

    *Note*: The `<cluster_name>` and `<base_domain>` of a cluster can be retrieved using the [ocm cli](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/accessing-clusters.md#ocm)

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

1. If your cluster is private, you should first make sure you can access it through ci.ext via VPC peering.

    1. Configure VPC peering to jumphost (ci.int) as needed for private clusters. See  [app-interface-cluster-vpc-peerings.md](app-interface-cluster-vpc-peerings.md).

        ```yaml
        peering:
          connections:
          - provider: account-vpc
            name: <cluster_name>_app-sre
            vpc:
              $ref: /aws/app-sre/vpcs/ci-int.yml
            manageRoutes: true
            manageAccountRoutes: true
        ```
