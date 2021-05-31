# How to bootstrap and use Tekton Pipelines for SaaS file deployments

## Background

This document explains how to use Tekton Pipelines as a pipeline provider for SaaS files.

This work was tracked in https://issues.redhat.com/browse/APPSRE-3187

## Process

1. Bootstrap
1. Usage
1. Monitoring
1. Migration from saas-file-1 (Jenkins provider) to saas-file-2 (Tekton provider)

### Bootstrap

In this section you will create:
- a Namespace to host your Tekton Pipelines
- a Pipeline Provider to reference from SaaS files
- a Role to obtain access to the Namespace

Perform the following actions in a single MR:

1. Create a Namespace file:
  ```yaml
  ---
  $schema: /openshift/namespace-1.yml

  labels:
    provider: tekton

  name: <service_name>-pipelines
  description: <service_name> pipelines namespace

  cluster:
    $ref: /openshift/appsrep05ue1/cluster.yml

  app:
    $ref: /services/app-sre/app.yml

  environment:
    $ref: /products/app-sre/environments/production.yml

  managedRoles: true

  managedResourceTypes:
  - Secret
  - Task
  - Pipeline
  - ClusterRole

  sharedResources:
  - $ref: /services/app-interface/shared-resources/app-sre-pipelines.yml
  ```

  * this file should be placed under `data/services/<service_name>/namespaces`.
  * copy the file as is and change only the service_name and the cluster:
    * use `appsre05ue1` for internal workloads (behind RH VPN, has access to gitlab). this will replace ci-int.
    * use `app-sre-prod-01` for external workloads. this will replace ci-ext.

2. Create a Pipelines Provider to reference the pipelines namespace:
  ```yaml
  ---
  $schema: /app-sre/pipelines-provider-1.yml

  labels: {}

  name: tekton-<service_name>-pipelines-appsrep05ue1
  description: tekton provider in the <service_name>-pipelines namespace in the appsrep05ue1 cluster

  provider: tekton
  namespace:
    $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml
  ```

  * this file should be placed under `data/services/<service_name>/pipelines`.
  * copy the file as is and change only the service_name and the namespace reference to match the location of the pipelines namespace file.

3. Create a Role to obtain access to view the pipelines namespace and to trigger deployments:
  ```yaml
  ---
  $schema: /access/role-1.yml

  labels: {}
  name: <service_name>-pipelines-appsrep05ue1-access

  permissions: []

  access:
  - namespace:
      $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml
    role: view
  - namespace:
      $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml
    role: tekton-trigger-access
  ```

  * copy the file as is and change only the `service_name` and the `namespace` references to match the location of the pipelines namespace file.
  * add this role under the `roles` section of the team's user files, or add the `access` entries to an existing role.


### Usage

Perform the following actions in a separate MR from the bootstrap MR:

1. Add a `pipelinesProvider` section to your SaaS file (only available for the `saas-file-2` schema):
  ```yaml
  pipelinesProvider:
    $ref: /services/<service_name>/pipelines/<service_name>-pipelines.appsrep05ue1.yaml
  ```

  * for more information of SaaS files please follow [Continuous Delivery in App-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md).

### Monitoring

TODO

### Migration

Perform the following actions in a separate MR from the bootstrap MR:

1. Change the SaaS file schema from `saas-file-1` to `saas-file-2`.
2. Replace the `instance` section with a `pipelinesProvider` as described in the Usage section.
3. Replace every `upstream` field with an `upstream` section:
  * `instance` - reference to Jenkins instance where upstream job exists
  * `name` - name of the Jenkins job to use as upstream (deploy upon build success)
