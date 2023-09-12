# All About Pyrra

## Overview

This goal of this document is to list all documents and tickets and knowledge share regarding the Pyrra integration we would like to implement.

## SOP

Here you an find the [SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/pyrra.md) that talks about the current components used in app-interface.

## Design document

Here you an find the [design doc](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/design-docs/pyrra-integration.md) that talks about the how we would like to implement Pyrra in our environment.

## Tickets

- Alerting ([APPSRE-8303](https://issues.redhat.com/browse/APPSRE-8303)): We want to make sure when we implement this service, we have a few basic alerts that will let us know how it is behaving out in OpenShift has well as if there are any problems with the UI itself since that will be the tool tenants will primarily use.
- New schema addition ([APPSRE-8304](https://issues.redhat.com/browse/APPSRE-8304)): We can implement a `pyrraSLO` property within the  `/app-sre/slo-document-1.yml` schema. With this change, we can then write an integration within qontract-reconcile that can turn the values within a `ServiceLevelObjective` object.
- Move existing SLOs to use Pyrra ([APPSRE-8305](https://issues.redhat.com/browse/APPSRE-8305)): This work will be a migration process where we can take already defined SLOs in app-interface and create a `pyrraSLO` property for each existing SLO.

## Other tickets to consider

- We may want to see if this service can fit into FedRAMP and if it can, what needs to be adjusted in order for it to happen. A key difference is that FedRAMP uses goalert so some investigation will need to be done to see how goalert works and how it will work with Pyrra.
