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

This questionnaire relates to the AWS S3 and RDS databases used by Tekton Results in the scope of the Pipeline Service component.

|                                   | Instructions                                                                                  | Answer |
|-----------------------------------|-----------------------------------------------------------------------------------------------|--------|
| Database schema migrations        | How will database schema migrations be performed?                                             | Tetkon Result controller is in charge of applying patches |
| Database schema rollbacks upgrade | Does the service handle schema rollbacks?                                                     | No |
| Forward/Backward compatibility    | Are schema changes made with forward/backward compatibility?                                  | No |
| Indexes                           | Do SQL Queries use indexes and appropriate secondary indexes?                                 | Yes |
| SSL connection                    | Does the service connect to the database over an SSL connection?                              | No. Tracked by PLNSRVCE-1094. |
| Data sensitivity                  | Does the database contain any sensitive information (like being able to identify a customer)? | Yes |    

## High-Level Goal

## SRE Purpose

As an SRE I have the guarantee that the service is managing the data in a way that is safe, secure, efficient and reliable. This will minimize outages caused by suboptimal data management capabilities.

## SaaS Instructions

- All data stores required as part of the service continuity must have an associated backup policy link on how backups and restores are handled for various types of datastores: pvs, rds, etc.

## Addon Instructions

- All data stores required as part of the service continuity must have an associated backup policy link on how backups and restores are handled for various types of datastores: pvs, rds, etc.
