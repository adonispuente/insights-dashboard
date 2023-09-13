# Configure an AppSRE cluster in app-interface

This guide describes how to dress up a cluster managed by AppSRE.

The cluster definition and access must have been setup in app-interface. See [cluster onboarding](/docs/app-sre/sop/app-interface-onboard-cluster.md) for the various options.

[TOC]

## Openshift-config

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
    - ClusterRoleBinding.rbac.authorization.k8s.io

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
    - resource: ClusterRoleBinding.rbac.authorization.k8s.io
      resourceNames:
      - dedicated-readers
      - self-provisioners

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

## Operator Lifecycle Manager (OLM)

1. Install the Operator Lifecycle Manager

   The Operator Lifecycle Manager is responsible for managing operator lifecycles.  It will install and update operators using a subscription.

    1. Create an `openshift-operator-lifecycle-manager.yml` namespace file for the cluster with this command:

    ```bash
    hack/cluster_provision.py [--datadir=data directory] create-olm-ns <cluster-name>
    ```

## Cert-manager operator

1. Follow the installation instructions in this [Runbook](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/runbook/cert-manager.md)

## Observability
1. Add Prometheus/Alertmanager DNS records to the [devshift.net DNS zone file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/devshift.net.yaml)
    ```bash
    hack/cluster_provision.py create-obs-dns-records <cluster>
    ```

1. Configure a [deadmanssnitch](https://deadmanssnitch.com/) snitch for the new cluster. The snitch settings should be as follow:
    - Name: prometheus.<cluster_name>.devshift.net
    - Alert type: Heartbeat
    - Interval: 15 min
    - Tags: app-sre
    - Alert email: sd-app-sre@redhat.com
    - Notes: Runbook: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/prometheus/prometheus-deadmanssnitch.md

1. Add the deadmanssnitch URL to this secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-input/alertmanager-integration
    - key: `deadmanssnitch-<cluster_name>-url`
    - value: the `Unique Snitch URL` from deadmanssnitch

1. Enable `openshift-customer-monitoring`:
    As of OpenShift 4.6.17, UWM (user-workload-monitoring) is enabled by default on OSD, replacing `openshift-customer-monitoring`. App-SRE still uses `openshift-customer-monitoring` and as such we need to disable UWM for us so we can use the current monitoring configs as described below. This is done through the OCM console (Settings -> uncheck "Enable user workload monitoring" -> Save).

    **`user-workload-monitoring` is disabled automatically by ocm_clusters integration. If you created the cluster through app-interface it should be already disabled**

    To enable `openshift-customer-monitoring` just run this command:
    ```bash
    hack/cluster_provision.py create-obs-customer-monitoring <cluster> <environment(integration|stage|production)>
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
      **If this is a private cluster, you need to add `CERT_MANAGER_ISSUER_NAME: letsencrypt-devshiftnet-dns` to `parameters`.**

  **Double check the changes introduced, the destination file could have been modified with manual changes**

**IMPORTANT**: Merge the changes and check that the integrations have completed running successfully. Check that `https://<prometheus|alertmanager>.<cluster_name>.devshift.net` have valid TLS certificates by accessing the URLs. If no security warning is given and the connection is secure as notified by the browser. If you do not see a valid TLS certificate, maybe you need to change the `CERT_ISSUER_NAME` attribute in the saas-nginx-proxy.yaml deployment. Remember that private clusters need to use DNS challenge solvers. See this [example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/61907). If you change the issuer name, make sure also to delete the old pending certificate requests: `oc delete certificaterequests.cert-manager.io alertmanager-...`

## Container Security Operator (CSO)

The Container Security Operator (CSO) brings Quay and Clair metadata to
Kubernetes / OpenShift. We use the vulnerabilities information in the tenants
dashboard and in the monthly reports.

To create the CSO operator configs, run the following command:

```bash
hack/cluster_provision.py [--datadir=data directory] create-cso-cluster-config <cluster-name>
```

Note: The prometheus rule for monitoring CSO deployment is already added through [template](https://gitlab.cee.redhat.com/service/app-interface/blob/master/hack/cluster_provision/templates/openshift-customer-monitoring.CLUSTERNAME.tpl).

Note: This may fail in HyperShift cluster first due to no permission for `app-sre-bot`, can retry after 2 hours since namespace creation or add `clusterAdmin: true` to `app-sre-cso-per-cluster.yml`.

## Deployment Validation Operator (DVO)

The Deployment Validation Operator inspects workloads in a cluster and evaluates them against know best practices.  It generates metric information about which workloads in which namespaces do not meet specific guidelines.  This information is presented in tenant dashboards and in monthly reports.

To create the DVO operator configs, run the following command:

```bash
hack/cluster_provision.py [--datadir=data directory] create-dvo-cluster-config <cluster-name>
```

Note: Skip this step for HyperShift cluster. [DVO-101](https://issues.redhat.com/browse/DVO-101)

## Cluster Logging

We run our custom logging stack. This requires creation of resources in the correct namespaces.

To enable the logging stack just run this command:
```bash
hack/cluster_provision.py --datadir data create-obs-logging <cluster> <environment(integration|stage|production)>
```
**Double check the changes introduced, the destination file could have been modified with manual changes**

This command does the following steps:
* Create the logging namespace configuration file `openshift-logging` under `/openshift/<cluster>/namespaces`
* Create the `event-router` namespace configuration file under `/openshift/<cluster>/namespaces`
* Add new target to resourceTemplate section to `/services/observability/cicd/saas/saas-event-router.yaml`

Check the created namespace template, it might fail the PR check since the CRD is not deployed at the begining. In that case, you'll need 2 PRs: one to install the operator and a second one to install the ClusterLogging and ClusterLogForwarder configurations.

In order to remove the configuration comment out the following line:
```
- $ref: /services/app-sre/shared-resources/cluster-logging-config.yaml
```

## Adding Datasource to Grafana

1. add grafana to `openshiftServiceAccountTokens` in `app-sre-observability-per-cluster.yml`, [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/458295334b65444dcbee5d9fc5e09e9a7b32a354/data/openshift/appsrep05ue1/namespaces/app-sre-observability-per-cluster.yml#L23-26)
1. add the cluster to [grafana.yaml](/data/services/observability/shared-resources/grafana.yml). Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/41110
 
    You can do that with this command:
      ```bash
      hack/cluster_provision.py create-obs-grafana-datasources <cluster>
      ```

    **Double check the changes introduced, the destination file could have been modified with manual changes.**

    Tip: There is one command to refresh all cluster info in shared grafana config,
    just in case console url changed but forgot to update `slug`.

      ```bash
      hack/cluster_provision.py refresh-obs-grafana-datasources
      ```

Datasource should be available afterwards.


# Additional configurations

## VPC peering with app-interface

[app-interface-cluster-vpc-peerings.md](app-interface-cluster-vpc-peerings.md)

## Additional steps for clusters for specific services

1. If the cluster is a hive shard, follow the [Hive shard provisioning SOP](/docs/app-sre/sop/hive-shard-provisioning.md)
2. If the cluster is a backplane cluster, follow the [Backplane cluster provisioning SOP](/docs/app-sre/sop/backplane-cluster-provisioning.md)
3. If the cluster is a console.redhat.com (crc) cluster, perform the following steps:
  * Deploy [3rd party operators](/data/services/insights/third-party-operators) (includes AMQ streams operator)
  * Deploy [Clowder operator](/data/services/insights/clowder)

## Hypershift: add workers machinepool

In contrast to OSD clusters, Hypershift clusters can not be scaled by increasing the nodes attribute in the cluster spec. The reason is, that Hypershift has a different implementation for machine pools than OSD/ROSA Classic clusters. It does not have the concept of a default machine pool. Thus you need to scale the cluster by scaling the machine pool.

Example, machine pool scaling:

```yaml
machinePools:
- id: workers
  instance_type: m5.xlarge
  replicas: 2
  subnet: subnet-0031fb992
```

In order to get the list of machinepools to add, run:

```bash
rosa list machinepools -c <clustername>
```
