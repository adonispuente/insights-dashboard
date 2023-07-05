# Initiative Document - Terraform v1 upgrade

## Author / Date

Krzysztof Wilczyński ([kwilczynski@redhat.com][author]) / June 2023

## Context

Currently, App-Interface relies on Terraform and the wealth of providers available to carry out work ranging from
provisioning resources in the Amazon AWS public cloud to managing various aspects of Cloudflare.

Users of App-Interface would define what type of resources and where they should be provisioned, and a number of
App-Interface integrations, such as, e.g., terraform-resources, terraform-users, terraform-cloudflare-dns, etc., would
then process the declarative configuration into a set of changes that would be then applied against whatever third-party
platforms and services are required, should there be any changes to be applied - the automatic reconciliation process
runs in regular intervals and takes into the account any additions, removals or updates for the resources App-Interface
manages. This takes place entirely transparently from the users' point of view.

The use of Terraform benefits App-Interface greatly as:

- It does not need to store any state of external infrastructure on its own
- It does not need to implement any code requiring intimate knowledge of the resources being managed
- It can rely on the maturity of many widely used Terraform providers gaining from the bug fixes and addition
  of new features as it taps into a vast network of users from the community who keep continuously working on
  improving Terraform and the surrounding ecosystem

## Problem Statement

Terraform has been in service of App-Interface and the AppSRE team for a while now, and during this time, we have
identified opportunities and areas for improvement in our workflow. Such areas include primarily maintenance,
orchestration, and maintainability. Let's address each area:

- **Maintenance:** We have been running Terraform version 0.13 for a while now, specifically release 0.13.7. This
  particular release is long past its end-of-life (EOL) [cycle][hashicorp-eol], as it was [released][terraform-release]
  over two years ago (April 27th, 2021). This means we are missing bugfixes and new features despite not using the
  bespoke DSL (Domain Specific Language) - we aren't using any of the features of the HCL language, which is a saving
  grace, as we are not impacted as much as its otherwise heavy users, should there be any bug fixes or new functionality
  specific to HCL that we would require. Additionally, having an old version of Terraform might also forbid us from
  being able to use [modern][terraform-promise] Terraform providers, such as the 5.x releases of the AWS provider, that
  rely upon and require the latest RPC protocol Terraform implements to exchange information between itself and the
  providers.

- **Orchestration:** How we run Terraform is unique as we aren't relying on the HCL language and templates to define our
  infrastructure and resources to manage. Our state, currently defined per account, is also relatively flat in terms of
  being completely self-contained, with each resource's interactions being limited primarily to implicit dependencies
  through the virtue of one consuming another's output. To generate this configuration, we use an Open Source project
  called [Terrascript][terrascript-github] that allows us to programmatically create a configuration file for Terraform
  to consume and execute against. Even though thus far everything seems like there aren't any issues with our approach
  currently, there is one fundamental problem with it: the Terrascript project was [deprecated][terrascript-deprecated]
  a while ago, and no active development had been taking place against it, as such it does not support any of the modern
  versions of Terraform which requires us to keep adding and maintaining more and more custom code to workaround its
  shortcomings.

  **Maintainability**: Aside from the large singular per account Terraform state, the Terrascript project created an
  artificial vendor lock-in for us, as we are currently unable to easily upgrade to a more modern version of Terraform
  as the upstream project does not include any support for Terraform 1.0 or newer - we have been working around lack of
  support for resources and specific functionality in Terrascript ourselves through extending our fork of the project as
  required. However, this results in a large, hard-to-maintain, and brittle (we almost have no test coverage to speak
  of) code base that keeps growing somewhat organically, some would say a little bit out of control - as it has become
  the proverbial hammer we apply to all Terraform-related problems.

Thus, with this initiative, we would like to start work, involving multiple different endeavours, towards upgrading to
the latest version of Terraform 1.x and retiring Terrascript to replace it with a custom, more tailor-made solution that
meets our needs.

## Goals

- Upgrade Terraform to the latest stable 1.x release to futureproof what providers and features we can support going forward
- Make it easier to carry out future Terraform and Terraform providers upgrades
- Retire use of the no longer maintained Terrascript project, and replace it with a more straightforward custom-made solution

## Milestones

### Milestone 0 - Define the scope of the work and collect requirements

This milestone focuses primarily on scoping the work and collecting requirements:

- Identify what the differences between Terraform 0.13 and the latest stable 1.x that will affect us are
- Collect use cases for Terrascript's future replacement
- Draft approach to future Terraform 1.x version rollout to existing accounts

### Milestone 1 - Retire and replace Terrascript

This milestone will focus on retiring and replacing the Terrascript project with a custom tailor-made solution.

The final deliverable will be a solution that will aim to replace Terrascript, but simpler and with better test
coverage, with the option to retire Terrascript using a completely different solution.

### Milestone 2 - Terraform upgrade delivered for non-production accounts

This milestone will focus on deploying Terraform 1.x to non-production accounts.

Several internal accounts will be selected as early adopters, and changes will be deployed there - at which point any
potential issues will be fixed.

The final deliverable will be a state where all the non-production environments run the latest Terraform 1.x version,
and Terraform configuration is assembled using a new Terrascript replacement.

### Milestone 3 - Terraform upgrade delivered for production accounts

This milestone will focus solely on orchestrating Terraform 1.x rollout to production environments where all the efforts
will be coordinated closely with the accounts owners.

The final deliverable will be a state where all the production environments are upgraded.

[author]: mailto:kwilczynski@redhat.com
[hashicorp-eol]: https://support.hashicorp.com/hc/en-us/articles/360021185113-Support-Period-and-End-of-Life-EOL-Policy
[terraform-release]: https://github.com/hashicorp/terraform/releases/tag/v0.13.7
[terraform-promise]: https://developer.hashicorp.com/terraform/language/v1-compatibility-promises
[terrascript-github]: https://github.com/starhawking/python-terrascript
[terrascript-deprecated]: https://github.com/starhawking/python-terrascript/issues/160
