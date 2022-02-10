# Continuous Testing in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their post deployment tests using a SaaS file.

## Overview

This SaaS file should deploy resources of kind `Job` to the same namespace as the application. The deployment of the Jobs should only be carried out after the application was deployed successfully.

The Jobs to deploy should be defined in a separate OpenShift template, and each Job name should end with `-{IMAGE_TAG}` so the jobs will be recreated after every update to the source code. The jobs from the previous round will be deleted automatically.

## Define post-deployment testing SaaS file

In order to define Continuous Testing pipelines in app-interface:

1. Define a SaaS file with a structure according to the [SaaS file structure](/docs/app-sre/continuous-delivery-in-app-interface.md#saas-file-structure), with the following specifications:
    * `managedResourceTypes` - should be only `Job`
    * `publishJobLogs` - (optional) if this is a [saas file running post-deployment tests](), set this to `true` to publish Jobs' pods logs.

2. Define an [automated promotion](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md#automatedgated-promotions) based on the results of the stage deployment.
    * Note: The usage of `upstream` to link post-deployment tests to a deployment job should be updated to use automated promotions. For more information: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/19968

A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/test.yaml).

### Define post-deployment testing for resources behind the Red Hat VPN

There may be use cases where tests need to access resources behind the Red Hat VPN, such as the OCM UI.

In order to run tests behind the VPN:

1. Create a namespace on the `appsres03ue1` cluster. Call the namespace the same as the app's stage namespace, including `-tests`.
    * Example: if the stage namespace is called `github-mirror-stage`, the internal tests namespace should be called `github-mirror-stage-tests`.
1. Follow the same process as mentioned above to create a SaaS file and automated promotions.
    * Note: the `pipelinesProvider` must be a reference to a provider behind the VPN as well (pipelines namespace should be in the `appsrep05ue1` cluster).
1. It is recommended to split the OpenShift template between tests that will run within the service namespace and tests that will run in the internal tests namespace.
