# Design doc: AWS Aurora Cluster SRE support for Quay.io

## Author/date
`jfchevrette` / `2023-06` 

## Tracking JIRA
[SDE-3092](https://issues.redhat.com/browse/SDE-3092)

## Problem Statement
Quay.io has a desire to migrate from RDS MySQL to RDS Aurora Postgresql for a few reasons:
* MySQL 5.x is EOL and will stop being supported after September 2023
* RDS Aurora will be cheaper than the current solution

## Goals
* Determine and agree on the mechanism by which we will configure and maintain the RDS Aurora infra for Quay.io
* Offer SRE Support RDS Aurora for Quay.io
  * Repo structure, management, lifecycling (ex: gitlab-fork-compliance, gitlab-housekeeping)
  * Second level assistance in troubleshooting terraform or AWS issues

## Non-objectives
* The specific resources, services and RDS Aurora infrastructure which will be provisioned for Quay.io
  * We are still learning about Aurora and thus we do not know how the exact infrastructure will look
* Anything about migration process - this will be a separate design doc
* Support RDS Aurora for tenants beyond Quay.io
* Support additional RDS Aurora features that are not strictly needed for Quay.io

## Proposal
We will create an independent git repository ([service/quayio-aurora-configs](https://gitlab.cee.redhat.com/service/quayio-aurora-configs)) in which we will store terraform configs that will make up the RDS Aura Cluster configs for Quay.io

This is inspired by [dynatrace-config](https://gitlab.cee.redhat.com/service/dynatrace-config/), albeit with a smaller scope. The same patterns can be re-used:
  * Have an OWNERS file
  * Added to app-interface under `codeComponents`, similarly to [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/9443116486e0cafab5fd2781396966b277e1226b/data/services/osd-operators/dynatrace/app.yml#L40-48)
  * Same general structure to keep familiarity amongst SREs

The main reason for going with this approach is two fold
* We are time-constrained: MySQL 5.x will be EOL in September 2023 and we also have to reserve time to migrate the existing Quay.io database to this new one
* It allow us to iterate quickly on building up the adequate Aurora infrastructure while lowering the initial barrier; not requiring extensive development (terraform-resources) and restricting ourselves to no manual operations on AWS accounts to ensure reproductibility

The bulk of the terraform configs will leverage community modules from https://github.com/terraform-aws-modules
  * [terraform-aws-rds-aurora](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/)
  * [terraform-aws-dms](https://github.com/terraform-aws-modules/terraform-aws-dms/)
  * [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc/)
  * ... and other needed to provision resources

The main community project we will be using [terraform-aws-rds-aurora](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/) is maintained by a person who is active on github and in the terraform-aws communities and projects

These terraform configs will be executed manually for the time being until we are able to integrate with [terraform-repo](terraform-repo.md)
  * Anothe reason to run manually for now is that many operations will take more than 15 minutes to execute. Namely, creating a 4 nodes cluster takes almost 30 minutes (on the AWS side). Adding, removing or upgrading nodes can take upward of 10 minutes.

### Pros/Cons

**Advantages**:
* Avoids re-inventing the wheel
* Scope is clear / self-contained
* Opportunity to contribute to a community project
* Avoids introducing long-running operations into a reconcile loop

**Disadvantages**
* Have to execute manually for the time being

### Proposal blueprints

**Note: The exact content of the terraform configs (resources, variables, etc...) is still TBD as research and experimentation with RDS Aurora is ongoing**

An existing repo (POC) is available here: https://gitlab.cee.redhat.com/jchevret/quayio-aurora-configs

The code is organized into enviromnents, under `terraform/<environment>` named after the same as in app-interface

AWS credentials will be retrieved from Vault, using OIDC login of the person executing the terraform plan

The state will be stored in the same AWS account as the resources that are created, in an S3 bucket named `quayio-aurora-cluster-terraform-<account_id>`

All parameters should be clearly visible in a `locals` section at the top of the `terraform.tf` file for ease of use. Users should not have to digg deeper into the file to find something, unless they are implementing a new variable or new functionnality

The various modules should be declared to use a specific major version. Ex: `version = "~> 8.3"`

The AWS providers should be set up with a descriptive alias, to better identify intent (`primary`, `secondary`)

Terraform `output`s to be declared to extract pertinent information
* Cluster endpoints
* Database name
* Credentials (?)

For the purpose of not losing trace of the resources created by this terraform config, we will add a placeholder `terraform-repo` provider entry in the usual place under `externalResources` for `quayio-stage` and `quayio-prod` such that engineers looking for these resources in the usual places will be able to find them and "follow the breadcrumbs" to the terraform repo. This is what a placeholder entry will look like

```yaml
# /data/services/quayio/namespaces/quayp05ue1.yml
# ...

externalResources:
- provisioner:
    $ref: /aws/quayio-stage/account.yml
  resources:
#  # This terraform-repo declaration is commented out until terraform-repo is available to use
#  # This is left here so that engineers will be able to locate it and execute manually
#  # Related resources: quayio-prod-aurora-cluster, quayio-prod-dms-migration, etc...
#  - provider: terraform-repo
#    repository: service/quayio-aurora-configs
#    ref: 1q2w3e4r5t
#    path: terraform/quayio-stage
```

### RDS Aurora operations to test and support

* Cluster creation
* Cluster config changes
* Cluster upgrades
* Node operations
  * Addition
  * Removal
  * Spec changes
* Backups / Snapshots
  * Scheduled autonated anspshots
  * Snapshot restore

All these operations MUST be documented in a `docs/` folder in the repository for SREs to consume

## Alternatives considered

### Automation via terraform-resources (qontract-reconcile)
The amount of work and heavylifting that the terraform-aws-aurora module does is non trivial. As such, duplicating the schemas and relationships into terraform-resources would be difficult to model and maintain over time.

Many of the necessary existing resources (VPCs, Subnets, Parameter groups) are coded in such a way that they are not immediately reuseable and as such, this has the likelihood of adding a lot of duplication to the integration

## Milestones
N/A
