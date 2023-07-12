# PostgreSQL RDS Upgrades - November 2023

[TOC]

The end of standard support for PostgreSQL 11 and minor versions is [November 2023](https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-release-calendar.html). To prevent issues we are asking tenants to upgrade their RDS versions. The minimum supported versions by AppSRE are documented [here](/README.md#approved-rds-versions), and teams must perform their due diligence by testing the impact of this required upgrade on their services.

## How do I know if my RDS instances are affected?

[Click here](/README.md#approved-rds-versions) for a list of approved RDS database engine versions.

- All DBs running PostgreSQL 11 are affected and need a database engine version upgrade.

## What do I need to do if I have an affected RDS instance?

- If your RDS instances are not running [approved versions](/README.md#approved-rds-versions), then you will need to [upgrade your database engine version in app-interface](/README.md#rds-minor-version-upgrades)

## Will these upgrades cause downtime?

Yes, you can expect downtime for upgrades. They will occur during the maintenance window you've configured for your RDS instance.

The downtime is associated with the database engine version upgrade, which you can read more about [here](/README.md#rds-minor-version-upgrades)

## Timeline

The timeline below summarizes the actions that need to be taken by each date.

| Deadline      | Tasks |
| ----------- | ----------- |
| ASAP      | 1. Teams using RDS should check if their databases are running the versions outlined [here](/README.md#approved-rds-versions)<br>2. Start upgrading the versions of your affected databases in the staging environment as soon as possible to provide sufficient time for testing       |
| November 6, 2023   | All stage and production databases should be running an [approved version of the database engine](/README.md#approved-rds-versions)       |
| November 13, 2023 14:00 UTC | AppSRE will schedule OS upgrades for the next RDS maintenance window after this deadline for all PostgreSQL databases running in staging/integration environments |
| November 27, 2023 14:00 UTC | Production RDS instances running PostgreSQL will have an OS upgrade applied to the instance during the next maintenance window after this deadline     |

## More questions?

Please [contact the AppSRE team](/FAQ.md#contacting-appsre) with any other questions.
