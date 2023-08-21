---
id: CONTINUITY-0003
category: CONTINUITY
summary: Data Management
docs:
  saas: https://todo/saas/continuity0003.md
  addon: https://todo/addon/continuity0003.md
---

# CONTINUITY-0003: Data Management

## Onboarding Questionnaire

This questionnaire relates to the RDS databases used by the GitOps Service component of RHTAP.

|                                   | Instructions                                                                                  | Answer |
|-----------------------------------|-----------------------------------------------------------------------------------------------|--------|
| Database schema migrations        | How will database schema migrations be performed?                                             | Migration upgrade/downgrade scripts are kept in [our project's GitHub repo](https://github.com/redhat-appstudio/managed-gitops/tree/main/utilities/db-migration/migrations) and are shipped within the [container image](https://github.com/redhat-appstudio/managed-gitops/blob/73b218892bb2aea3f167529ed5b61f129bfdfebb/Dockerfile#L54) of the controller. On controller startup, [golang-migrate](https://github.com/golang-migrate/migrate) automatically upgrades to the latest expected version defined within the container image. |
| Database schema rollbacks upgrade | Does the service handle schema rollbacks?                                                     | Yes, by running the corresponding 'down' migration to the target version.  |
| Forward/Backward compatibility    | Are schema changes made with forward/backward compatibility?                                  | Yes. GitHub Actions [[1]](https://github.com/redhat-appstudio/managed-gitops/blob/73b218892bb2aea3f167529ed5b61f129bfdfebb/.github/workflows/static.yml#L217) [[2]](https://github.com/redhat-appstudio/managed-gitops/blob/73b218892bb2aea3f167529ed5b61f129bfdfebb/.github/workflows/static.yml#L203) [[3]](https://github.com/redhat-appstudio/managed-gitops/blob/73b218892bb2aea3f167529ed5b61f129bfdfebb/.github/workflows/static.yml#L167) exists within the repository to ensure that all up/down migrations will correctly produce the expected database state. These run as part of every PR and programmatically ensure that team members don't produce invalid upgrade/downgrade migration scripts.|
| Indexes                           | Do SQL Queries use indexes and appropriate secondary indexes?                                 | Yes. We recently (July 2023) audited our code to ensure all queries have a corresponding primary/secondary index. These are documented within the code via 'Index Name is' comments. Indices are defined in the central `db-schema.sql` [master schema](https://github.com/redhat-appstudio/managed-gitops/blob/main/db-schema.sql). |
| SSL connection                    | Does the service connect to the database over an SSL connection?                              | It connects to app-interface RDS, which defaults to TLS-only, but the service does not currently require TLS-only (opening us up to MITM attacks). This will be improved with [GITOPSRVCE-731](https://issues.redhat.com/browse/GITOPSRVCE.-731). |
| Data sensitivity                  | Does the database contain any sensitive information (like being able to identify a customer)? | Yes |    

## High-Level Goal

## SRE Purpose

As an SRE, I have the guarantee that the service is managing the data in a way that is safe, secure, efficient and reliable. This will minimize outages caused by suboptimal data management capabilities.

## SaaS Instructions

- All data stores required as part of the service continuity must have an associated backup policy link on how backups and restores are handled for various types of data stores: PVS (i.e., EBS), RDS, etc.

## Addon Instructions

- All data stores required as part of the service continuity must have an associated backup policy link on how backups and restores are handled for various types of data stores: PVS (i.e., EBS), RDS, etc.
