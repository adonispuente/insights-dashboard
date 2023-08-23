# Design Document - Read Replica Requirement Waiver for GABI

[toc]

## Author / Date

Krzysztof Wilczyński (kwilczynski@redhat.com) / August 2023

## Tracking JIRA

[APPSRE-7135](https://issues.redhat.com/browse/APPSRE-7135)

## Problem statement

Historically, when requesting a GABI instance to be deployed for a particular service, the tenant had to provide a read
replica as one of the requirements, or a matter of an established policy, if you wish.

However, the policy requiring a read replica for GABI has been relaxed recently to keep the operating cost down - a lot
of these RDS instances were using the same node type as the primary database, often driving the monthly cost up, and
were idle for the most part since GABI service is often used solely for troubleshooting.

Services deployed into a production environment are still required to provide a read replica. However, a service owner
can now apply for a waiver to absolve such a service, following a formal approval process, from having to deploy a read
replica for its GABI instance. The waiver process will operate on a case-by-case basis and require managerial sign-off
to be given the go-ahead.

Thus, we need to introduce changes to the GABI schema to allow teams to put in a waiver.

## Goals

* Allow tenants to apply for a read replica requirement waiver when requesting a GABI instance to be deployed for their
  service into a production environment.

## Non-Goals

N/A

## Proposal

Add a simple text attribute to the GABI schema that accepts a pledge for a tenant or provided by a tenant that would
spell out risks that the tenant takes as part of being granted the read replicas requirements waiver.

We can also supply the text of the pledge for tenants to use as a template, for example:

> I request that the read replicas requirement be waived for my service \<SERVICE NAME\> for the accompanying GABI
> instance deployment in the production environment. I hereby accept risks related to using a primary production
> database instance to carry-out troubleshooting activities, which is the intended use case of the GABI service.

### Proposed Schema Changes

[gabi-instance-schema][.../schemas/app-sre/gabi-instance-1]:

```yaml
diff --git i/schemas/app-sre/gabi-instance-1.yml w/schemas/app-sre/gabi-instance-1.yml
index 6e71231..f9e028c 100644
--- i/schemas/app-sre/gabi-instance-1.yml
+++ w/schemas/app-sre/gabi-instance-1.yml
@@ -15,6 +15,8 @@ properties:
     "$ref": "/common-1.json#/definitions/extendedIdentifier"
   description:
     type: string
+  readReplicasWaiverPledge:
+    type: string
   signoffManagers:
     type: array
     items:
```

[gabi-instance-schema]: https://github.com/app-sre/qontract-schemas/blob/main/schemas/app-sre/gabi-instance-1.yml

## Alternatives Considered

* Use a boolean attribute type instead of a text one. Perhaps include explicit references to a manager or managers who
  signed off on the waiver.

## Milestones

1. Update the GABI schema to include the new attribute.
2. Reach out to tenants who are interested in running a GABI instance without the need to deploy a read replica for
   their service, whatever the reason, explain the process to them, and help them cut over their GABI instance to their
   primary database instance, if needed.
