# RDS instance already exists error for newly created database

## Description

There are two most common reasons why a newly created RDS database instance might not be persisted within the Terraform
state:

  - The Pod that runs the `terraform-resources` integration was terminated
  - Terraform run has timed out while creating a resource

Nowadays, creating a new [Multi-AZ][multi-az-aws] or an uncommon (in terms of type) RDS instance can take a long time
(over 40 minutes).

During the `terraform apply`, a default timeout is applied while creating each of the resources, including the
`aws_db_instance`, as such when Terraform reaches a [timeout][terraform-timeouts] on creation (or update), the newly
created RDS instance or updates to the current state might not be persisted in the Terraform state.

Thus, any subsequent reconciliation attempt will try to create the DB again due to drift. The AWS API will also return
the `DBInstanceAlreadyExists` error when an RDS instance with the same identifier already exists.

## Recovery

To recover a newly created RDS database instance that is currently causing a drift, resulting in the
`terraform-resoures` integration terminating with an error, it must be imported into the current Terraform state. This
can be done as follows:

1. Disable `terraform-resources` integration to ensure that no changes to the existing state occur during recovery
   (integrations run on regular intervals).

    There are two ways an integration can be disabled:

    - Adding integration under the `disable` section and `integrations` properly for a given shard (account)
    - Using [Unleash][app-interface-unleash] to disable integration entirely for all shards

    Disabling integration only for a specific shared is the preferred way. For more details about how to disable an
    integration, see: [Disable qontract-reconcile integrations for specific resources][disable-integration]

1. Obtain a `config.tf.json` using `qontract-reconcile` CLI, run:

    `--log-level DEBUG --dry-run --config <CONFIG FILE> --dry-run terraform-resources --account-name <SHARD NAME> --print-to-file=/tmp/config.tf.json`

1. Run `terraform init` in the directory where the `config.tf.json` file is stored to download any missing providers and
   initialise the state

1. Run `terraform plan` to verify the plan is indeed trying to create the already existing RDS database

1. Run `terraform import aws_db_instance.<RDS INSTANCE IDENTIFIER> <RDS INSTANCE IDENTIFIER>` to import the RDS database
   into the current state

1. Run `terraform plan` to verify the instance is now part of the state. **Note:** Some attributes, such as the database
   password, might still show as a required update, which is fine - not all attributes are imported from AWS as part of
   the import process

1. Enable `terraform-resources` again to allow other pending changes to be applied

Assuming that the import process and subsequent Terraform run were successful, there should be no more drift, and the
`terraform-resoures` integration should no longer fail with an error.

[multi-az-aws]: https://aws.amazon.com/rds/features/multi-az
[terraform-timeouts]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#timeouts
[app-interface-unleash]: https://app-interface.unleash.devshift.net
[disable-integration]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-disable-integrations.md
