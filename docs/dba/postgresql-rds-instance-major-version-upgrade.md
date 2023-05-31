# Upgrade Major Version for PostgreSQL RDS Instance

- [Upgrade Major Version for PostgreSQL RDS Instance](#upgrade-major-version-for-postgresql-rds-instance)
  - [Major Version Upgrade vs. Minor Version Upgrade](#major-version-upgrade-vs-minor-version-upgrade)
  - [AWS Documentation](#aws-documentation)
  - [Steps for Upgrade at High Level](#steps-for-upgrade-at-high-level)
    - [Note About Upgrading Read-Replicas](#note-about-upgrading-read-replicas)
    - [Known issues](#known-issues)
  - [app-interface changes for upgrading](#app-interface-changes-for-upgrading)
    - [1. Terminate Read Replicas](#1-terminate-read-replicas)
      - [Remove Read Replica Dependency](#remove-read-replica-dependency)
      - [Read Replicas Termination and Config Updates](#read-replicas-termination-and-config-updates)
    - [2. Scale DOWN the application](#2-scale-down-the-application)
    - [3. Create a New Parameter Group and Update Engine Version](#3-create-a-new-parameter-group-and-update-engine-version)
    - [4. Prepare post-upgrade queries](#4-prepare-post-upgrade-queries)
      - [ANALYZE](#analyze)
    - [5. Start Database Upgrade](#5-start-database-upgrade)
      - [Terraform Resource - errors](#terraform-resource---errors)
    - [6. Monitor upgrade](#6-monitor-upgrade)
    - [7. Run post-upgrade queries](#7-run-post-upgrade-queries)
    - [8. Scale UP the application](#8-scale-up-the-application)
    - [9. Create read-replicas](#9-create-read-replicas)
    - [10. Update Application Config Changes to use read replicas](#10-update-application-config-changes-to-use-read-replicas)

This document outlines the steps and expectations for a major version upgrade of a PostgreSQL RDS instance.

## Major Version Upgrade vs. Minor Version Upgrade

There are two kinds of upgrades: major version upgrades and minor version upgrades. In general, a _major engine version upgrade_ can introduce changes that are not compatible with existing applications. In contrast, a _minor version upgrade_ includes only changes that are backward-compatible with existing applications.

## AWS Documentation
The following documentations are _must_ read for anyone considering a _major engine version upgrade_.

- [Upgrading the PostgreSQL DB Engine for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html)
- [Best practices for upgrading Amazon RDS to major and minor versions of PostgreSQL](https://aws.amazon.com/blogs/database/best-practices-for-upgrading-amazon-rds-to-major-and-minor-versions-of-postgresql/)

## Steps for Upgrade at High Level

---

**Teams should not attempt this process without working closely with AppSRE. This is not a self-service process.**

---

This section provides helpful information and an overview of the steps that your team will need to perform for a PostgreSQL major version upgrade.

1. The upgrade duration is based on how much storage your database uses, whether you have read-replicas, and other factors. A **dry-run upgrade is highly recommended for services with high availability requirements**. A stage database is rarely a good representation of how long a production database will take to upgrade.
   * You should be prepared for the upgrade to take up to **6 hours**. Someone from AppSRE team will need to be available for the duration of the upgrade.
   * A dry-run upgrade typically involves [restoring the RDS instance from a backup](/README.md#restoring-rds-databases-from-backups) and then upgrading the restored database.
2. Confirm the upgrade path using the [AWS docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion). Note that you may need to upgrade the minor version of your database engine for a major version upgrade to be available.
3. Identify a time window that works for the development team and AppSRE to upgrade the stage database.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
4. The service team writes a [runbook](/docs/app-sre/maintenance-windows.md#Runbooks) for performing the upgrade that includes step-by-step instructions for carrying out all aspects of the upgrade. This should include several pieces of information:
   * Write step-by-step instructions for stopping the service before upgrade and starting the service after upgrade. If we do not want to stop the service during the upgrade time, we will need dev teams to monitor the service during upgrade process and document the expected behavior.
   * Create any merge requests ahead of time and link to them from the runbook
   * An example can be found [here](https://docs.google.com/document/d/1EbY27pT6M_LXPKH01emMBbww7WkUrgXXSQff9t-EjiI/edit#heading=h.uh9g57272rj1)
5. After successfully upgrading your stage database, reach out to stakeholders and get approval to upgrade production.
   1. **RDS upgrade will result in downtime for your application. Plan for 6 hour outage for the upgrade.**
6. Identify a time window that works for the development team and AppSRE to upgrade the production database.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
   2. Upgrades should be started early in the morning. AppSRE will not approve upgrades that start after 10am ET.
7. Notify your customers of the planned outage by posting the necessary banners on `Pendo` and `Statuspage`.
8. **The AppSRE team will execute the [runbook created by the development team](/docs/app-sre/maintenance-windows.md#Runbooks)**

### Note About Upgrading Read-Replicas

Upgrading RDS instances that have read-replicas is a bit more complicated for PostgreSQL. AWS recommends that you **delete and recreate read-replicas after the source instance has upgraded to a different major version.**

### Known issues

This section tracks any issues related to major version upgrades.

1. Databases with many schemas - databases with many schemas, typically a result of a tenant-per-schema configuration which can lead to thousands or more schemas, can take a very long time to complete a major version upgrade (24+ hours for tens of thousands of schemas)

## app-interface changes for upgrading

This section provides the high-level steps required to perform the major version upgrade using app-interface. This section should be used to create the step-by-step instructions specific to the database that is being upgraded.

---

**Several of the steps below will require an AppSRE team member to complete them. This is not a self-service process. Do not attempt to perform these steps without having read the earlier sections and having scheduled time with AppSRE.**

---


### 1. Terminate Read Replicas

#### Remove Read Replica Dependency

1. Deploy configuration changes so that your application will stop using read replica instances.

#### Read Replicas Termination and Config Updates

1. Update your parameter group to remove any parameters related to replication.
2. Raise MR to app-interface to delete the read-replica instance. This step will have to be executed by AppSRE team member.
   * Remember to set `deletion_protection` to `false` for the read replica instance.
   * Add the rds instance and the parameter group to the account [deletionApprovals](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#enable-deletion-of-aws-resources-in-deletion-protected-accounts) if deletion protection is enabled for the AWS account, e.g. [insights-prod](https://gitlab.cee.redhat.com/service/app-interface/-/blob/0c447b6df71b3ac52c97233a30d0a8778d8d8657/data/aws/insights-prod/account.yml#L40).
3. Drop the `Logical replication slots`. This step will have to be [executed by AppSRE team member](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/dba/connect-to-postgres-mysql-database.md). If the database is using logical replication slots, the major version upgrade fails and shows the message `PreUpgrade checks failed: The instance could not be upgraded because one or more databases have logical replication slots. Please drop all logical replication slots and try again`. To resolve the issue, stop any running DMS or logical replication jobs and drop any existing replication slots. See the following code:

```
   SELECT * FROM pg_replication_slots;
   SELECT pg_drop_replication_slot(slot_name);
```
In case the slot can not be dropped with the following error: `ERROR:  replication slot "slot_name" is active for PID XXXXX`:
```
   SELECT pg_cancel_backend(pid);
```

Example MR: [Terminate read-replica and disable deletion protection](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/47213/diffs)

### 2. Scale DOWN the application

Raise MR that sets the deployment's replica count to `0`.

Example MR: [Scale down service](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9695)

### 3. Create a New Parameter Group and Update Engine Version

Create a copy of your current parameter group and update at least the following 2 things:

1. `family` : The family of the DB parameter group.
2. `name` : The name of the DB parameter group. Must be unique.

At this point, the file exists but is not referenced by your RDS instance. This change can be combined with the next step.

1. Update the `engine_version` for your RDS instance in either the defaults file or add it to the overriding section.
   * **IMPORTANT:** if changing a defaults file, you will upgrade every database that uses that defaults file, so take care in changing this setting. You can grep for the defaults filename to see where it is used and confirm that only the expected databases will be changed in the MR dry-run build.
2. Add `allow_major_version_upgrade: true` to your RDS defaults file to allow the upgrade. Terraform will fail if this flag is not set.
3. Update `parameter_group` reference to use the new parameter group file. Keep the old value which will be used in the step below.
4. Add/Update `old_parameter_group` with the old value from above step. This is to ensure we keep parameter group until the terraform run is complete. 
   * If the RDS instance has already been updated in the past through this procedure, then terraform will delete the unused parameter group (referenced via `old_parameter_group` before the field was updated through step #4). This is expected and will be reflected in app-interface JSON validation report. This **will not** impact RDS upgrade. 
5. Add `apply_immediately: true` in the overrides section within RDS provider configuration.
6. The MR will be reviewed by the AppSRE team. They will not merge the MR until the upgrade is ready to begin.

Example MRs: [Upgrade RDS Instance from PostgreSQL 11.x to 12.x & Create PostgreSQL 12 parameter group](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/47924/diffs)

### 4. Prepare post-upgrade queries

Usually you need to run some queries to ensure optimal performance of your database after the upgrade. You must prepare these queries prior to upgrading the database. Consult `Execute a SQL Query on an App Interface controlled RDS instance` in the README on how to submit a MR to app-interface for executing a query. In the MR description, mention that the query is related to a database upgrade and must only be merged after the upgrade successfully ran.

The query will receive lgtm from AppSRE and get merged/executed **after** the database was successfully upgraded.

#### ANALYZE

Prepare `ANALYZE` operation to refresh the `pg_statistic` table. You should do this for every database on all your PostgreSQL DB instances. Optimizer statistics aren't transferred during a major version upgrade, so you need to regenerate all statistics to avoid performance issues. Run the command without any parameters to generate statistics for all regular tables in the current database, as follows:

```
ANALYZE VERBOSE
```

There are potentially more queries involving `REINDEX` or `VACUUM`, however, there is no general rule of thumb for these and they depend on the changes the major version upgrade includes.

### 5. Start Database Upgrade

Start by merging the MR that was created to upgrade the database. When qontract-reconcile runs next, the upgrade will be applied immediately. 

---

#### Terraform Resource - errors

qontract-reconcile might throw following errors:

```
[terraform-resources] error: b'\nError: Error modifying DB Instance cyndi-stage: InvalidParameterCombination: Cannot upgrade postgres from 10.18 to 12.11\n\tstatus code: 400, request id: f7a65b84-13e6-479b-843f-079c6204c61f\n\n  on config.tf.json line 13512, in resource.aws_db_instance.cyndi-stage:\n13512:       },\n\n\n'
```

This error can be misleading because AWS does support upgrade from 10 to 12, but only from 10.18 to 12.8 not 10.18 to 12.11. Similarly, please check the table in https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion to find the list of specific versions that your version can be upgrade to.


```
[terraform-resources] error: b'\nError: Error modifying DB Instance dev-bhthakur-rds: InvalidParameterValue: Cannot modify engine version because another engine version upgrade is already in progress\n\tstatus code: 400, request id: 2fdb9061-630e-4ed7-97ed-86b6acd5cbcc\n\n  on config.tf.json line 1978, in resource.aws_db_instance.dev-bhthakur-rds:\n1978:       },\n\n\n'
```

```
[terraform-resources] error: b"\nError: Error modifying DB Instance dev-bhthakur-rds: InvalidParameterCombination: There are still pending changes to the instance's Parameter Group. Please wait for them to finish.\n\tstatus code: 400, request id: 6dac65f5-8994-4ae7-84f4-801f3fad5713\n\n  on config.tf.json line 1978, in resource.aws_db_instance.dev-bhthakur-rds:\n1978:       },\n\n\n"
```

This behavior is inconsistent and is documented [here](https://github.com/hashicorp/terraform-provider-aws/issues/24908)

**If you see this error, there is no need to take any action. Terraform will soon reconcile the state as soon as the upgrade is complete on AWS side.**


### 6. Monitor upgrade

Monitor the upgrade in AWS console. AWS will run a pre-upgrade check and the upgrade may not proceed if pre-upgrade check fails. The AWS docs linked above have troubleshooting steps if you run into errors with pre-upgrade checks.

### 7. Run post-upgrade queries

The queries prepared in [step 4](#4-prepare-post-upgrade-queries) must be merged by AppSRE. `sql-query` integration will then execute the queries. 

### 8. Scale UP the application

When the RDS instance status changes to `Available`, scale the application back to usual capacity. At this point your application will still not use read-replica as none exist.

Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9716

### 9. Create read-replicas

Now re-create the read-replica instances by adding them back to app-interface.

### 10. Update Application Config Changes to use read replicas

Update your application configuration to use the read replicas.
