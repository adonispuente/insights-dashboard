# RDS OS Upgrades - June 2022

[TOC]

AWS RDS released [OS upgrades](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Mandatory_OS_Updates) to improve the security posture of RDS instances. This OS upgrade can only be applied to databases that are running fairly recent database engine minor versions, which we have documented [here](/README.md#approved-rds-versions). Many RDS instances that are managed in app-interface are currently running older versions that will require an upgrade.

This means that there are two distinct upgrades that will be required for most databases - a minor version upgrade of the database engine and an OS upgrade for the RDS instance. Minor version upgrades of database engines are typically backwards-compatible, but teams will need to perform their due diligence and test the impact of the upgrade on their services.

## How do I know if my RDS instances are affected?

[Click here](/README.md#approved-rds-versions) for a list of approved RDS database engine versions.

1. If you aren't running an approved minor version of your database engine, then your RDS instance is affected and will need both a database engine minor version upgrade and an OS upgrade
2. If you are running an approved minor version, then your RDS instance is only affected if it has a [pending maintenance activity](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#USER_UpgradeDBInstance.Maintenance.Viewing)

## What do I need to do if I have an affected RDS instance?

1. If your RDS instances are not running [approved versions](/README.md#approved-rds-versions), then you will need to [upgrade the database engine minor version in app-interface](/README.md#rds-minor-version-upgrades)
2. Once your database is running a compliant engine minor version, then the OS upgrades will be automatically applied during your RDS instance maintenance window as follows:
   * **PostgreSQL**
     * The OS upgrade will be applied during the next maintenance window after June 30, 2022
   * **MySQL**
     * The OS upgrade will be applied during the next maintenance window after your database engine is upgraded (the deadline for MySQL was January 31, 2022)
     * After March 30th, any MySQL instance that is upgraded to an approved database engine minor version will have the OS upgrade applied at any time, whether in a maintenance window or not (see the [AWS docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Mandatory_OS_Updates))

## Will these upgrades cause a downtime?

Yes, you can expect a downtime for each of the two upgrades. They will occur during the maintenance window that you've configured for your RDS instance.

1. The first downtime is associated with the database engine minor version upgrade, which you can read more about [here](/README.md#rds-minor-version-upgrades)
2. The second downtime is associated with the OS upgrade. RDS instances configured to use Multi-AZ will have minimal downtime (fail over is typically <1 minute) because the OS upgrade is performed on the standby instance first, and then the primary will fail over to the secondary instance

### Can I combine these two upgrades?

We are not suggesting that teams attempt to perform both upgrades at the same time for a couple of reasons:

1. Upgrading the database engine minor version and the RDS instance operating system at the same time can make it difficult to know which upgrades caused an issue if any issues with your service are detected
2. RDS OS upgrades cannot be scheduled in app-interface today

For teams that complete the minor version engine upgrade before June 1st, there will be roughly a month in between the two upgrades. Please reach out to AppSRE if your team has specific concerns.

## Timeline

The timeline below summarizes the actions that need to be taken by each date.

| Deadline      | Tasks |
| ----------- | ----------- |
| ASAP      | 1. Teams using RDS should check if their databases are running the versions outlined [here](/README.md#approved-rds-versions)<br>2. Start upgrading the minor versions of your affected databases in stage as soon as possible to provide sufficient time for testing       |
| June 1, 2022   | All stage and production databases should be running [approved versions of the database engine](/README.md#approved-rds-versions)       |
| June 2-14, 2022 | AppSRE will schedule OS upgrades during the RDS maintenance window for all PostgreSQL databases running in staging environments |
| June 30, 2022   | Production RDS instances running PostgreSQL will have an OS upgrade applied to the instance during the next maintenance window after this deadline (AWS will schedule this automatically)      |

## More questions?

Please [contact the AppSRE team](/FAQ.md#contacting-appsre) with any other questions.
