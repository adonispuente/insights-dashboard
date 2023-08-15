# Design doc: Database schema manager

[toc]

## Author/date

Jan-Hendrik Boll / August 2023

## Tracking JIRA

[APPSRE-8131](https://issues.redhat.com/browse/APPSRE-8131)

## Problem Statement

We are handing out the master DB user to tenants, this user has very broad permissions [1]. This is a security risk that could be mitigated by having users with limited permissions. However, App-Interfaces does not support user/access management for databases.

Especially for use cases where we want to share a database instance between multiple components, we need to be able to manage the schemas and users on the database instance.

## Goals

Specify the required qontract-schema changes and implementation details for the database schema manager.

## Nongoals

Revisiting existing database instances and reducing permissions.

## Proposals

### Schema

Add a new schema called `database-schema`. This can be used to specify required users and permissions on a schema. The schema configuration should be reusable over integration/stage/production. 

Example schema configuration:
```yaml
---
$schema: /app-interface/database-schema.yml

name: guestbook
username: gb-app
schema: guestbook

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
  schemas:
    - $ref: /terraform/resources/app-sre/production/important-database-guestbook.yml
  output_resource_name: important-database-root
  schema_output_prefix: important-database
```

### Database schema manager

The database schema manager should be able to create and delete schemas and users on a database instance. It should be able to read the configuration from `/app-interface/database-schema.yml` schemas and apply it to the database instance.

The schema manager should create a random password for the db user created and store it in a secret beside the main database password. The additional secret should also be stored in the output path, next to the main secret. The name will be: `$schema_output_prefix-$schema.name`, in our example: `important-database-guestbook`

The schema manager should be agnostic of the engine used, for Postgres we'll start by using psycopg [2].


## Alternatives considered

Add schema management to terraform-resources, as i.e. null-resource with a script would not be able to reconcile the state of the database schema with the configuration.

## Milestones

* Create qontract-schema change
* Implement database manager for Postgres Databses
* Update documentation


## References

[1] https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.MasterAccounts.html
[2] https://www.psycopg.org/docs/usage.html#passing-parameters-to-sql-queries
