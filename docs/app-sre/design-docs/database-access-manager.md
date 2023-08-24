# Design doc: Database access manager

[toc]

## Author/date

Jan-Hendrik Boll / August 2023

## Tracking JIRA

[APPSRE-8131](https://issues.redhat.com/browse/APPSRE-8131)

## Problem Statement

We are handing out the master DB user to tenants, this user has very broad permissions [1]. This is a security risk that could be mitigated by having users with limited permissions. However, App-Interfaces does not support user/access management for databases.

Especially for use cases where we want to share a database instance between multiple components, we need to be able to manage the databases and users with their permissions on the instance.

## Goals

Specify the required qontract-schema changes and implementation details for the database access manager.

## Nongoals

* Revisiting existing database instances and reducing permissions
* Managing permissions on individual tables

## Proposals

### Qontract Schema

Add a new schema called `database-access`. This can be used to specify required users and permissions on a database. The access configuration should be reusable over integration/stage/production. 

Example schema configuration:
```yaml
---
$schema: /app-interface/database-access-1.yml

name: guestbook
username: gb-app
database: gb

# Set delete: True to delete the user and database
# delete: True

grants:
  - select
  - insert
  - update
  - delete
  - truncate
```

This configuration can be specified in the external resource of the database instance.

Example reference in namespace:
```yaml
- provider: rds
  identifier: important-database
  availability_zone: us-east-2b
  defaults: /terraform/resources/app-sre/production/rds-1-us-east-2.yml
  databases:
    - $ref: /terraform/resources/app-sre/production/important-database-guestbook.yml
  output_resource_name: important-database-root
  database_output_prefix: important-database
```

### Database access manager

The database access manager should be able to create and delete databases and users on an instance. It should be able to read the configuration from `/app-interface/database-access-1.yml` schemas and apply it to the database instance.

The access manager should create a random password for the db user created and store it in a secret beside the main database password. The additional secret should also be stored in the output path, next to the main secret. The name will be `$database_output_prefix-$-databaseaccess.name`, in our example: `important-database-guestbook`. If `$database_output_prefix` is not set, it will be the same as the `$identifier` of the rds resources.

The access manager should be agnostic of the engine used, for Postgres we'll start by using psycopg [2].


## Alternatives considered

Add database management to terraform-resources, as i.e. null-resource with a script would not be able to reconcile the state of the database with the configuration.

## Milestones

* Create qontract-schema change
* Implement database manager for Postgres Databses
* Update documentation


## References

1. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.MasterAccounts.html
2. https://www.psycopg.org/docs/usage.html#passing-parameters-to-sql-queries
