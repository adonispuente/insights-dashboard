This doc summarizes the cluster setup process for a Backplane ROSA STS/Privatelink cluster

[TOC]

# Account onboarding

Use these steps to setup a new account to host ROSA clusters. This is needed only once per account. Those are TL;DR, follow the links for a more detailed procedure.

* [Account onboarding](/docs/app-sre/sop/add-aws-account.md)
  * [setup the root creds](/docs/aws/sop/root-account-credentials.md), with 2FA
  * setup terraform user & bucket as described in [docs/aws/terraform](/docs/aws/terraform)
  * create the `/aws/account-1.yml` and `/dependencies/terraform-state-1.yml` manifests in app-interface. Grant accesses.
* [ROSA account configuration](/docs/app-sre/runbook/openshift-rosa-clusters.md#aws-account-configuration)
  * Enable the ROSA Service from the marketplace
  * `aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"`
    * This creates load balancer role.
  * `rosa init`
  * `rosa create ocm-role --admin --mode auto --yes`
    * This allows OCM to interact with the AWS account.
  * `rosa create account-roles --mode auto --yes`
    * This creates roles in the AWS account for installer, SRE, masters and workers
  * `rosa create user-role --mode auto --yes`
    * This links the current OCM user with the AWS account by creating a Role and referencing it in OCM. It is best to run this with a bot account.

# Cluster setup

Backplane clusters need to be STS and Privatelink. This section is a TL;DR; for the [Rosa STS/Privatelink cluster setup](/docs/app-sre/runbook/openshift-rosa-clusters.md#create-a-new-rosa-sts-privatelink-cluster)

## Pre-reqs

Setup the cluster network. BYOVPC (Bring-Your-Own-VPC) is mandatory for privatelink clusters.
* Reuse the account terraform bucket for the state, use a dedicated name for the tfstate
* Example: https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/718

## Set variables and context
Let's use some variables to make the following scriptlets generic
```sh
CLUSTER_NAME="backplanei02ue1"
ACCOUNT_NAME="sd-infra-stage-01"
ACCOUNT_UID="611491592236"
REGION="us-east-1"

# The --channel-group option is enabled according to some capability
# possible value: candidate, fast, stable
CHANNEL_GROUP="candidate"
# CHANNEL_GROUP="fast"
# CHANNEL_GROUP="stable"
VERSION="4.13.0"

# Info from terraform run in the app-sre/infra repository to create the VPC.
# Example: https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/718
VPC_CIDR="10.170.36.0/22"
SUBNET_IDS="subnet-0d88d4c1650b1b0f7,subnet-09914bd4f38ec2822,subnet-0d3ea5d08e5519882"

COMPUTE_MACHINE_TYPE="m5.xlarge"
REPLICAS="9"

ROLE_PREFIX="OCM-Prod-"
INSTALLER_ROLE_ARN=arn:aws:iam::${ACCOUNT_UID}:role/ManagedOpenShift-${ROLE_PREFIX}Installer-Role
SUPPORT_ROLE_ARN=arn:aws:iam::${ACCOUNT_UID}:role/ManagedOpenShift-${ROLE_PREFIX}Support-Role
CONTROL_PLANE_ROLE_ARN=arn:aws:iam::${ACCOUNT_UID}:role/ManagedOpenShift-${ROLE_PREFIX}ControlPlane-Role
WORKER_ROLE_ARN=arn:aws:iam::${ACCOUNT_UID}:role/ManagedOpenShift-${ROLE_PREFIX}Worker-Role
```

OCM login with the bot
```sh
qontract-cli --config ... get ocm-login ocm-production
# and run that command ...
```

export the AWS profile to the account
```sh
export AWS_PROFILE=${ACCOUNT_NAME}
```

## Create the cluster

Request the cluster creation
```sh
rosa create cluster \
--cluster-name ${CLUSTER_NAME} \
--yes \
--sts \
--private \
--private-link \
--multi-az \
--role-arn "${INSTALLER_ROLE_ARN}" \
--support-role-arn "${SUPPORT_ROLE_ARN}" \
--controlplane-iam-role "${CONTROL_PLANE_ROLE_ARN}" \
--worker-iam-role "${WORKER_ROLE_ARN}" \
--region ${REGION} \
--version ${VERSION} \
--channel-group ${CHANNEL_GROUP} \
--replicas ${REPLICAS} \
--compute-machine-type ${COMPUTE_MACHINE_TYPE} \
--service-cidr 172.30.0.0/16 \
--pod-cidr 10.128.0.0/14 \
--host-prefix 23 \
--machine-cidr ${VPC_CIDR} \
--subnet-ids ${SUBNET_IDS}
```

<details><summary>Example output</summary>

```
W: In a future release STS will be the default mode.
W: --sts flag won't be necessary if you wish to use STS.
W: --non-sts/--mint-mode flag will be necessary if you do not wish to use STS.
W: No OIDC Configuration found; will continue with the classic flow.
W: You are choosing to use AWS PrivateLink for your cluster. STS clusters can only be private if AWS PrivateLink is used. Once the cluster is created, this option cannot be changed.
I: Creating cluster 'backplanei02ue1'
I: To view a list of clusters and their status, run 'rosa list clusters'
I: Cluster 'backplanei02ue1' has been created.
I: Once the cluster is installed you will need to add an Identity Provider before you can login into the cluster. See 'rosa create idp --help' for more information.

Name:                       backplanei02ue1
ID:                         247jc96vf02mfg61aot9nveceifbokvi
External ID:
Control Plane:              Customer Hosted
OpenShift Version:
Channel Group:              candidate
DNS:                        Not ready
AWS Account:                611491592236
API URL:
Console URL:
Region:                     us-east-1
Multi-AZ:                   true
Nodes:
 - Control plane:           3
 - Infra:                   3
 - Compute:                 9
Network:
 - Type:                    OVNKubernetes
 - Service CIDR:            172.30.0.0/16
 - Machine CIDR:            10.170.36.0/22
 - Pod CIDR:                10.128.0.0/14
 - Host Prefix:             /23
STS Role ARN:               arn:aws:iam::611491592236:role/ManagedOpenShift-Installer-Role
Support Role ARN:           arn:aws:iam::611491592236:role/ManagedOpenShift-Support-Role
Instance IAM Roles:
 - Control plane:           arn:aws:iam::611491592236:role/ManagedOpenShift-ControlPlane-Role
 - Worker:                  arn:aws:iam::611491592236:role/ManagedOpenShift-Worker-Role
Operator IAM Roles:
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-cluster-csi-drivers-ebs-cloud-cre
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-cloud-network-config-controller-c
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-machine-api-aws-cloud-credentials
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-cloud-credential-operator-cloud-c
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-image-registry-installer-cloud-cr
 - arn:aws:iam::611491592236:role/backplanei02ue1-n7h8-openshift-ingress-operator-cloud-credential
Managed Policies:           No
State:                      waiting (Waiting for OIDC configuration)
Private:                    Yes
Created:                    Jun  8 2023 07:32:54 UTC
Details Page:               https://console.redhat.com/openshift/details/s/2Quhrl7r6XFTmAxTSZ2vc3DsP01
OIDC Endpoint URL:          https://rh-oidc.s3.us-east-1.amazonaws.com/247jc96vf02mfg61aot9nveceifbokvi (Classic)

I:
Run the following commands to continue the cluster creation:

	rosa create operator-roles --cluster backplanei02ue1
	rosa create oidc-provider --cluster backplanei02ue1

I: To determine when your cluster is Ready, run 'rosa describe cluster -c backplanei02ue1'.
I: To watch your cluster installation logs, run 'rosa logs install -c backplanei02ue1 --watch'.
```
</details>

The 2 next steps are needed for the cluster install to really kick in.
We use the `--cluster ${CLUSTER_NAME}` parameter to link roles automatically.

Create the AWS roles that will be used by various operators
```sh
rosa create operator-roles --cluster ${CLUSTER_NAME} --mode auto
```

<details><summary>Example output</summary>

```
I: Creating roles using 'arn:aws:iam::611491592236:user/terraform'
I: Created role 'backplanei02ue1-f5o5-openshift-cloud-credential-operator-cloud-c' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-cloud-credential-operator-cloud-c'
I: Created role 'backplanei02ue1-f5o5-openshift-image-registry-installer-cloud-cr' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-image-registry-installer-cloud-cr'
I: Created role 'backplanei02ue1-f5o5-openshift-ingress-operator-cloud-credential' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-ingress-operator-cloud-credential'
I: Created role 'backplanei02ue1-f5o5-openshift-cluster-csi-drivers-ebs-cloud-cre' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-cluster-csi-drivers-ebs-cloud-cre'
I: Created role 'backplanei02ue1-f5o5-openshift-cloud-network-config-controller-c' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-cloud-network-config-controller-c'
I: Created role 'backplanei02ue1-f5o5-openshift-machine-api-aws-cloud-credentials' with ARN 'arn:aws:iam::611491592236:role/backplanei02ue1-f5o5-openshift-machine-api-aws-cloud-credentials'
```
</details>

Create the OIDC provider. That's what will allow Kubernetes Service accounts to map to AWS roles, using STS.
```sh
rosa create oidc-provider --cluster ${CLUSTER_NAME} --mode auto --yes
```

<details><summary>Example output</summary>

```
I: Creating OIDC provider using 'arn:aws:iam::611491592236:user/terraform'
I: Created OIDC provider with ARN 'arn:aws:iam::611491592236:oidc-provider/rh-oidc.s3.us-east-1.amazonaws.com/247jc96vf02mfg61aot9nveceifbokvi'
```
</details>

(Optional) Watch cluster creation progress
```sh
rosa logs install -c ${CLUSTER_NAME} --watch
```

After that we have a STS/Privatelink cluster running in our pre-configured VPC.

## Make the cluster endpoints DNS records public

Within the cluster AWS account, copy all DNS records records from the cluster private hostedzone to its public hostedzone.
This is manual for now. The script [hack/copy-rosa-private-dns-records](/hack/copy-rosa-private-dns-records) can be used to perform this copy.
```sh
# ACCOUNT_PROFILE = the name of your local AWS profile to connect to the cluster's AWS account
# CLUSTER_NAME = the name of the cluster to copy the records for
./hack/copy-rosa-private-dns-records $ACCOUNT_PROFILE $CLUSTER_NAME
```

# Onboard the cluster in app-interface

* From the [cluster onboarding guide](/docs/app-sre/sop/app-interface-onboard-cluster.md):
  * Setup the cluster.yml `auth` with `redhat-app-sre-auth`
* https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/70663
  * Create a network-mgmt-${CLUSTER_NAME} role in an other namespace (will be moved later)
* https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/70664
  * initial cluster import, including peerings using the role above

After that, you can have access to the cluster with you own account, via `sshuttle`. 

Let's continue the standard onboarding steps from the [app-interface setup](/docs/app-sre/sop/app-interface-onboard-cluster.md#app-interface-setup) step. Again, those are TL;DR;. Please refer to the links for more details

* create the `app-sre-bot` and `app-sre-cluster-admin-bot` serviceaccounts and store their token in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/)
* openshift config ([example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/70699))
  * enable `jumpHost`, `automationToken`, `clusterAdmin` and `clusterAdminAutomationToken` fields in `cluster.yml`
  * configure the `openshift-config` namespace
  * configure the `openshift-operator-lifecycle-manager` namespace
    * `hack/cluster_provision.py create-olm-ns ${CLUSTER_NAME}`
* cert-manager as per the [dedicated SOP](/docs/app-sre/runbook/cert-manager.md) (3 MR)
* observability
  * Observability DNS records `hack/cluster_provision.py create-obs-dns-records ${CLUSTER_NAME}`
  * Monitoring `hack/cluster_provision.py create-obs-customer-monitoring ${CLUSTER_NAME} <environment(integration|stage|production)>`
  * [DeadManSnitch](https://deadmanssnitch.com/)
  * CSO: `hack/cluster_provision.py create-cso-cluster-config ${CLUSTER_NAME}`
  * DVO `hack/cluster_provision.py create-dvo-cluster-config ${CLUSTER_NAME}`
  * Logging operator
    * `hack/cluster_provision.py create-obs-logging ${CLUSTER_NAME} <environment(integration|stage|production)>`
    * comment out the logging config
  * [Grafana datasource](/docs/app-sre/runbook/app-interface-dressup-cluster.md#adding-datasource-to-grafana)
    * `openshiftServiceAccountTokens` in `/openshift/${CLUSTER}/namespaces/app-sre-observability-per-cluster.yml`
* observability configs
  * logging config
  * Grafana datasource: `hack/cluster_provision.py create-obs-grafana-datasources ${CLUSTER}`


# Backplane specifics

## ALLOWED_CIDR_BLOCKS in Managed Cluster Configs (MCC)
Get the backplane cluster egress IP addresses from [clusters-network.md](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/clusters-network.md) and add them to the list of `ALLOWED_CIDR_BLOCKS` for MCC in [/services/osd-operators/cicd/saas/saas-managed-cluster-config.yaml](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/osd-operators/cicd/saas/saas-managed-cluster-config.yaml). Note that teh cluster should be added only to the correspondiong environment MCCs: integration / stage / production.

## TGW attachements
Backplane clusters need some TGW attachements to `osd-privatelink-*` accounts. This allows conectivity to hive privatelink clusters as well as all Hypeershift hosted clusters. This is done in the `cluster.yml` manifest.

## hiveconfig
Backplane clusters need to be added in hiveconfigs' `spec.awsPrivateLink.associatedVPCs`. This tells the hive operator to associate privatelink privatehosted zones from the `osd-privatelink-<environment>` account to the cluster VPC. This allows DNS resolution of privatelink clusters.

See for example:
- [VPC service account setup](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/72741)
- [Hive config update]()

## AVO
Backplane clusters need to be added in hypershift AVO configurations so each HostedCluster gets reachable via privatelink
Example:
- [set a service account allowing AVO to manipulate VPC route53 associations in the cluster account](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/71551/diffs)
- [provide the creds of this service account & some configuration to AVO](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/71543/diffs)
