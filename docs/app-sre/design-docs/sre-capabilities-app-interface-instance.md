# Design doc: app-interface instance for sre-capabilities

## Author/date

Gerd Oberlechner / Maor Friendman / Patrick Martin - August 2023


## Tracking JIRA

https://issues.redhat.com/browse/SDE-3341

## Problem Statement

Currently base data and runtime configuration for sre-capabilities reside in  [app-interface commercial](https://gitlab.cee.redhat.com/service/app-interface), which complicates data ownership and sovereignty. It also blurs the lines between the two different user groups of app-interface:

* classic tenants that undergo ROMS
* capability users that consume offerings à la carte without any onboarding

Mixing these two usecases and their data was an agreed compromise for the time being, to allow for a quick path to enable capabilities, but needs to be addressed sooner than later.

## Goals

Move sre-capabilities to a dedicated runtime and configuration space separate from app-interface commercial. This goal aligns with Milestone 3 of the [sre-capabilities initiative](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/initiatives/sre-capabilities.md#milestone-3-capabilities-runtime).

## Non-objectives

Define a model for app-interface instances as a service (as a capability).

## Proposal

Create a new app-interface instance named `sre-capabilities` that will hold all configuration and runtime information for sre-capabilities and that manages the execution of capabilities.

### Repository content

The `sre-capabilities` repo will be structurally aligned to what app-interface commercial provides - if you are familiar with commercial you will be with sre-capabilities.

The repo will contain the declarations of integrations to run as capabilities (as `integration-1.yml` files) along with some required base configuration data (e.g. OCM environment for OCM related capabilities like AUS and RH-IDP).

### Infrastructure management

For the actual runtime of an app-interface instance, a set of infrastructural requirements need to be fulfilled.

* an S3 bucket to hold bundles for the repo
* a namespace to run qontract-server and integrations-manager (and subsequently also the integrations)
* CI jobs for bundling and PR checks

For the setup of all this infrastructure and processes we propose to use app-interface commercial as the ignition and management engine, ramping namespaces, defining CI jobs, creating resources on AWS, deploying a qontract-server via saas, ...

The sre-capabilities instance will be `just another service` managed by app-interface commercial.

# Milestones

## Milestone 1

Create a new repository and fill it with base data and configuration to enable the execution of sre-capabilities. Ignite the entire infrastructure to run the new app-interface instance and put PR check, merge processes and bundling processes in place.

During this Milestone we will try to change as little as possible/necessary on schemas, integrations and hack scripts, with the purpose to proof the concept by migrating a capability to that new runtime and configuration space.

We have a PoC up right now in https://gitlab.cee.redhat.com/service/sre-capabilities. See [APPSRE-8161](https://issues.redhat.com/browse/APPSRE-8161) for the work that has been done for ignition in app-interface commercial. Right now we only added a small schema change to allow us a [lean configuration of a namespace](https://github.com/app-sre/qontract-schemas/pull/499) for integrations-deployment from `integration-1.yml` files.

## Milestone 2

Reevaluate the way we drive PR-checks and bundling with the current state of the hack scripts. Having multiple app-interface instances makes it a burden to keep such scripts in sync across repositories. As a matter of fact, it is a burden already to the fedramp team that tries to stay close/compatible with commercial. In this milestone we want to reevaluate the ideas brought up in [APPSRE-6333](https://issues.redhat.com/browse/APPSRE-6333) that revolve around CI-code being shareable with all app-interface instances.

## Milestone 3

Promotions of all evolving components of an app-interface instance is delicate business. Making sure a stack composed of qontract-server, schemas, integrations, CI-code, etc. that works well in commercial can be replicated with ease to the sre-capabilities app-interface instance and potentially also Fedframp.
