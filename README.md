# App-Interface

This repository serves as a central coordination point for hosted services being
run by the Application SRE team. Many or all of the portions of the contract
defined herein will be handled through automation after changes are accepted to
this repository by the appropriate parties.

The Application SRE team is responsible of fulfilling the contract defined in
this repository.

## Overview

This repository contains of a collection of files under the `data` folder.
Whatever is present inside that folder constitutes the App-SRE contract.

These files can be `yaml` or `json` files, and they must validate against the some
[well-defined json schemas][schemas].

The path of the files do not have any effect on the integrations (automation
components that feed off the contract), but the contents of the files do. They
will all contain:

- `$schema`: which maps to a well defined schema [schema][schemas].
- `labels`: arbitrary labels that can be used to perform queries, etc.
- Additional data specific to the resource in question.

## Components

Main App-Interface contract components:

- <https://gitlab.cee.redhat.com/service/app-interface>: datafiles (schema
  implementations) that define the contract. JSON and GraphQL schemas of the datafiles.
- <https://github.com/app-sre/qontract-server>: The GraphQL component developed
  in this repository will make the datafiles queryable.

Additional components and tools:

- <https://github.com/app-sre/qontract-validator>: Python script that validates
  the datafiles against the json schemas hosted in `qontract-server`.
- <https://github.com/app-sre/qontract-reconcile>: automation component that
  reconciles the state of third-party services like `github`, with the contract
  definition.

The word _qontract_ comes from _queryable-contract_.

## Workflow

The main use case happens when an interested party wants to submit a contract
amendment. Some examples would be:

- Adding a new user and granting access to certain teams / services.
- Submitting a new application to be hosted by the Application SRE team.
- Modifying the SLO of an application.
- etc.

All contract amendments must be formally defined. Formal definitions are
expressed as json schemas. You can find the supported schemas here:
[schemas][schemas].

1. The interested party will:

- Fork the [app-interface](<https://gitlab.cee.redhat.com/service/app-interface>
) repository.
- [Share their fork](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html#sharing-a-project-with-a-group-of-users) of the `app-interface` repository with the [devtools-bot](https://gitlab.cee.redhat.com/devtools-bot) user as `Maintainer`.
- Submit a MR with the desired contract amendment.

2. Automation will validate the amendment and generate a report of the desired
   changes, including changes that would be applied to third-party services like
   `OpenShift`, `Github`, etc, as a consequence of the amendment.

3. The Application-SRE team will review the amendment and will determine whether
   to accept it by merging the MR.

4. From the moment the MR is accepted, the amended contract will enter into
   effect.

## Local validation of datafile modifications / contract amendment

Before submitting a MR with a datafile modification / contract amendment, the
user has the option to validate the changes locally.

Two things can be checked: (1) JSON schema validation (2) run integrations with
`--dry-run` option.

Both scripts rely on a temporary directory which defaults to `temp/`, but can be
overridden with the env var `TEMP_DIR`. The contents of this directory will
contain the results of the manual pr check.

### JSON schema validation

Instructions to perform JSON schema validation on changes to the datafiles.

**Requirements**:

- docker
- git

**Instructions**:

Run the actual validator by executing:

```sh
# make sure you are in the top dir of the `app-interface` git repo
source .env
make bundle validate # output is data.json
```

The output will be JSON document, so you can pipe it with `jq`, example:
`cat data.json | jq .`

### Running integrations locally with `--dry-run`

Instructions in [this document](/docs/app-sre/sop/running-integrations-manually.md).

## Querying the App-interface

The contract can be queried programmatically using a
[GraphQL](<https://graphql.org/learn/>) API.

The GraphQL endpoint is reachable here:
<https://app-interface.devshift.net/graphql>.

You need to authenticate to access the service. Please request the credentials
to the App-SRE team.

**IMPORTANT**: in order to use the GraphQL UI you need to click on the Settings
wheel icon (top-right corner) and replace `omit` with `include` in
`request.credentials`.

## Features

### Existing Features

- [GraphQL API](<https://github.com/app-sre/qontract-server>).
- Ability to validate all schemas as valid JSON-Schema and compliant with the
  integration metaschema.
- Ability to validate all datafile (schema implementations) that implement a
  schema.
- Validation of datafiles on MRs to the `app-interface` repository.
- Simulation of third-party service changes on MRs to `app-interface`
  repository.
- Automated deployment of the new contract to the production GraphQL endpoint.
- Automated execution of the supported integration components to reconcile other
  services with the desired state as represented in the contract.

### Planned Features

- Automatically generate GraphQL schemas from the JSON schemas.
- Automated reporting based on the contract via GraphQL API.
- Auditability and traceability. Being able to easily track down when and why an
  amendment was submitted.

## Integrations

### Existing integrations

- GitHub org and team syncing. With this integration we can leverage any service
  that is configured to use GitHub as the authentication platform. For example:
  - <https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/>
  - <https://ci.ext.devshift.net/>
  - <https://vault.devshift.net/ui/>
  - Many OpenShift [clusters](/data/openshift)
  - OpenShift.io Feature Toggles
- Management of OpenShift rolebindings
- Management of Quay repos.
- Management of Quay mirrors.
- Management of Quay organisation members.
- Management of Sentry users.
- Management of Sentry teams.
- Management of Sentry projects.
- Management of openshift-acme deployments.
- Management of OpenShift Namespaces.
- Management of OpenShift Groups.
- Management of OpenShift LimitRanges.
- Management of OpenShift resources.
- Management of OpenShift Secrets using Vault.
- Management of OpenShift Routes using Vault.
- Management of Vault configurations.
- Management of cluster monitoring, such as prometheus and alert manager.
- Management of AWS resources.
- Management of AWS users.
- Management of Slack User Groups.
- Management of Jenkins jobs configurations.
- Management of Jenkins roles association.
- Management of Jenkins plugins installation.
- Deletion of orphan AWS resources.
- Deletion of AWS keys per AWS account.
- House keeping of GitLab issues.
- Compliance validation of GitHub user profiles.
- Management of GitLab groups.
- Creation of GitLab projects.
- Deletion of OpenShift users.
- Management of notification e-mails.
- Management of SQL Queries.

### Planned integrations

- Top level tracking of managed services, their contact points, and work
  streams.
- Management of OLM catalog entries for managing service operators.

## Howto

### Add or modify a user (`/access/users-1.yml`)

You will want to do this when you want to add a user or grant / revoke
permissions for that user.

Users are typically stored in the `teams/<name>/users` folder. Note that the
actual file path will not condition the integrations, you can consider the
directory structure as something that is only useful for human consumption.

Write the file in yaml format with `.yml` extension. The contents must validate
against the current [user schema][userschema].

Make sure you define `$schema: /access/users-1.yml` inside the file.

The `roles` property is the most complex property to understand. If you look at
the `/access/users-1.yml` you will see that it's a list of [crossrefs][crossref].
The `$ref` property points to another file, in this case it must be a
[role][role]. The role file is essentially a collection of
[permissions][permission]. Permissions contain a mandatory property called
`service` which indicate what kind of permission they are. The possible values
are:

- `github-org`
- `github-org-team`
- `quay-org-team`

In any case, you typically won't need to modify the roles, just find the role
you want the user to belong to. Roles can be associated with the services:
`service/<name>/roles/<rolename>.yml`, or to teams:
`teams/<name>/roles/<rolename>.yml`. Check out the currently defined roles to
know which one to add.

### Get notified of events involving a service, or it's dependencies

There are three ways a user or group can get notified of service events (e.g. planned maintenance, outages):

* `serviceOwner`:  Point of contact for communications from Service Delivery to service owners.  Where possible, this should be a development team mailing list (rather than an individual developer).  This field is Required.
* `serviceNotifications`:  This is a list of additional email addresses of employees who would like to receive notifications about a service.  This field is Optional.
* Subscribe to the `sd-notifications@redhat.com` [mailing list](https://post-office.corp.redhat.com/mailman/listinfo/sd-notifications). This list receives all event communications.

Find out more about App-SRE Incident Procedures [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md#168-incident-procedure).

Example usage for [Hive](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/hive/app.yml):

```
serviceOwners:
- name: Devan Goodwin
  email: dgoodwin@redhat.com

serviceNotifications:
- name: Hive Mailing list
  email:  aos-hive@redhat.com
```

### Create a Quay Repository for an onboarded App (`/app-sre/app-1.yml`)

Onboarded applications are modelled using the schema `/app-sre/app-1.yml`. This schema allows any application to optionally define a list required Quay repositories.

The structure of this parameter is the following:

```yaml
quayRepos:
- org:
    $ref: <quay org datafile (`/dependencies/quay-org-1.yml`), for example `/dependencies/quay/openshiftio.yml`>
  items:
  - name: <name of the repo, e.g. 'centos'>
    description: <description>
    public: <true | false>
    mirror: (optional) <upstream repository to sync the Quay repo from, e.g. 'docker.io/centos'>
  - ...
```

In order to add or remove a Quay repo, a MR must be sent to the appropriate App datafile and add the repo to the `items` array.

**NOTE**: If the App or the relevant Quay org are not modelled in the App-Interface repository, please seek the assistance from the App-SRE team.

### Create a Sentry Project for an onboarded App (`/app-sre/app-1.yml`)

The structure of this parameter is the following:

```yaml
sentryProjects:
- team:
    $ref: <sentry team datafile (`/dependencies/sentry-team-1.yml`), for example `/dependencies/sentry/teams/app-sre-stage.yml`>
  projects:
  - name: <name of the project>
    description: <description of the project>
    email_prefix: <email prefix for emails about the project>
    platform: <project language>
    sensitive_fields:
    -  <sensitive field for the project>
       ...
    safe_fields:
    -  <safe field for the project>
       ...
    auto_resolve_age: (optional) <integer hours for auto resolving, default never>
    allowed_domains:
    - <allowed domain for the project>
      ...
  - ...
- ...
```

The name, description, email-prefix, and platform fields are required, whereas the other fields are optional.

In order to add or remove a Sentry project, a MR must be sent to the appropriate App datafile and the project needs to be added to or remoted from the projects array.

### Create a Sentry Team (`/dependencies/sentry-team-1.yml`)

Sentry projects are associated to sentry teams, with only the members of the team able to view the issues of the associated projects.

To define a sentry team create a file in /data/dependencies/sentry/teams with a structure like the following:

```yaml
---
$schema: /dependencies/sentry-team-1.yml

labels:
  service: app-sre

name: app-sre
description: App-SRE official sentry-stage team
instance: 
  $ref: /dependencies/sentry/sentry-stage.yml
```

The instance is a reference to a sentry instance.  This is the sentry instance where the team will be created.

### Manage Sentry team membership via App-Interface (`/access/role-1.yml`)

Sentry users and team membership can be entirely self-serviced via App-Interface.

In order to get access to Sentry, a user has to have:
* A `role` that includes a `sentry_teams` section, with one or more references to sentry team file(s).
    * Example: [dev](/data/teams/sd-uhc/roles/dev.yml) role.

### Manage Openshift resources via App-Interface (`/openshift/namespace-1.yml`)

[services](/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

Notes:
* If the resource already exists in the namespace, the PR check will fail. Please get in contact with App-SRE team to import resources to be under the control of App-Interface.
* Manual changes to resources will be overridden by App-Interface in each run.
* If a resource has a `qontract.recycle: "true"` annotation, all pods using that resource will be recycled on every update.
  * Supported resources: Secrets

OpenShift resources can be entirely self-serviced via App-Interface. A list of supported resource types can be found [here](/schemas/openshift/namespace-1.yml#L46).

Some resources have special caracteristics and are described further below. These have a specific `provider` value.
- `Secret`
- `Route`

For other resources, two `provider` options are available:
- `resource`
- `resource-template`

The `resource-template` provider supports using the `Jinja2` template language to extend the capabilities of the integration. In addition to the [standard Jinja2 language](https://jinja.palletsprojects.com/en/2.10.x/), the following additional capabilities are supported:
- Fetch a secret from vault

    ```jinja
    {{ vault('app-sre/creds/smtp', 'username') }}
    ```

- Base64 encode a block of data

    ```jinja
    {% b64encode %}
    My data
    {% endb64encode %}
    ```

- Reference the resource & namespace metadata from app-interface

  The `resource` variable is passed to Jinja2 and contains all the resource/namespace metadata as returned by the integration at the point of processing the resource

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ resource.name }}
  data:
    foo: bar
  ```

> **Warning**: The Jinja2 delimiters (`{{ }}` and `{% %}`) conflicts with other templating languages such as go's text/template. To remedy that, the `type` `extracurlyjinja2` can be used to add an extra curly brace to the standard Jinja2 delimiters (resulting in `{{{ }}}` and `{{% %}}`

The next section demonstrates how to manage a `ConfigMap` resource via two examples showing both the `resource` and `resource-template` providers:

#### Example: Manage a ConfigMap via App-Interface (`/openshift/namespace-1.yml`)

In order to add ConfigMaps to a namespace, you need to add them to the `openshiftResources` field.

- `provider`: must be `resource`
- `path`: path relative to [resources](/resources). Note that it starts with `/`.

The object itself must be stored under the `resources` path, and by convention it should be named: `resources/<cluster_name>/<namespace>/<configmap_name>.configmap.yml`.

In order to change the values of a ConfigMap, send a PR modifying the ConfigMap in the `resources` directory, and upon merge it will be applied.

#### Example: Manage a templated ConfigMap via App-Interface (`/openshift/namespace-1.yml`)

A templated opensource resource is configured the same way as a standard resource, with the following changes:

- `provider`: must be `resource-template`
- `type`: can be `jinja2` or `extracurlyjinja2` (default is `jinja2`)

An example of the file content could be:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
type: Opaque
data:
  not_so_secret_value: {{{ vault('app-interface/my-cluster/my-namespace/my-not-so-secret-secret', 'the-key') }}}
```

#### Manage Secrets via App-Interface (`/openshift/namespace-1.yml`) using Vault

Instructions:

1. Create a secret in Vault with the data (key-value pairs) that should be applied to the cluster.
  * The secret in Vault should be stored in the following path: `app-interface/<cluster>/<namespace>/<secret_name>`
  * The value of each key in the secret in Vault should **NOT** be base64 encoded.
  * If you wish to have the value base64 encoded in Vault, the field key should be of the form `<key_name>_qb64`.
2. Add a reference to the secret in Vault under the `openshiftResources` field ([example](/data/services/openshift.io/namespaces/bayesian-preview.yml#L43))with the following attributes:

- `provider`: must be `vault-secret`.
- `path`: absolute path to secret in [Vault](https://vault.devshift.net). Note that it should **NOT** start with `/`.
- `version`: version of secret in Vault.
- `name`: (optional) name of the Kubernetes Secret object to be created. Overrides the name of the secret in Vault.
- `labels`: (optional) labels to add to the Secret.
- `annotations`: (optional) annotations to add to the Secret.
- `type`: (optional) type of the Kubernetes Secret to be created. Defaults to `Opaque` if not specified.

3. In order to change one or more values in a Kubernetes Secret, update the secret in Vault first and submit a new MR with the updated `version` field.
  * The current version can be found in Vault on the top-right of the list of values for your secret.

Notes:

* [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) with fields of type `stringData` are not supported.
* When creating a new secret in Vault, be sure to set the `Maximum Number of Versions` field to `0` (unlimited).
* If you want to delete a secret from Vault, please get in contact with the App-SRE team.
* If you wish to use a different secrets engine, please get in contact with the App-SRE team.
* To create a secret in a `production` environment, please get in contact with the App-SRE team.

Example:

This secret in Vault:
```
{
  "key": "value",
  "otherkey_qb64": "dmFsdWUy"
}
```
Would generate this Kubernetes Secret:
```yaml
apiVersion: v1
kind: Secret
data:
  key: dmFsdWU=
  otherkey: dmFsdWUy
type: Opaque
```

#### Manage Routes via App-Interface (`/openshift/namespace-1.yml`) using Vault

Routes can be entirely self-serviced via App-Interface.

In order to add Routes to a namespace, you need to add them to the `openshiftResources` field.

- `provider`: must be `route`
- `path`: path relative to [resources](/resources). Note that it starts with `/`.
- `vault_tls_secret_path`: (optional) absolute path to secret in [Vault](https://vault.devshift.net) which contains sensitive data to be added to the `.spec.tls` section.
- `vault_tls_secret_version`: (optional, mandatory if `vault_tls_secret_path` is defined) version of secret in Vault.

Notes:
* The secret in Vault should be stored in the following path: `app-interface/<cluster>/<namespace>/routes/<secret_name>`.
* In case the Route contains no sensitive information, a secret in Vault is not required (hence the fields are optional).
* It is recommended to read through the instructions for [Secrets](#manage-secrets-via-app-interface-openshiftnamespace-1yml-using-vault) before using Routes.

### Manage openshift-acme deployments via App-Interface (`/openshift/acme-1.yml`)

This integration allows namespace owners to deploy openshift-acme to their namespaces.

To deploy and manage an openshift-acme instance, a user must add the following to a namespace declaration:

```yaml
openshiftAcme:
  config:
    $ref: /dependencies/openshift/acme/default.yml
```

The openshift-acme deployment can be customized by creating a new file alongside the default one.

The default definition (as shown above) is self-documented and shows how to tweak the openshift-acme deployment.

An optional acme-account secret in Vault can be declared in the following way:

```yaml
openshiftAcme:
  config:
    $ref: /dependencies/openshift/acme/default.yml
  accountSecret:
    provider: vault-secret
    path: vault/path/to/acme-account
    version: 1
```

For namespaces in which the secret names are restricted, we can specify which secret names the `openshift-acme` service account via the `acmeSecrets` array

### Manage OpenShift Groups association via App-Interface (`/openshift/cluster-1.yml`)

[openshift](/data/openshift) contains all the clusters that are managed by the App-SRE team. Inside of those directories, there is a `cluster.yml` file that describes the cluster.

Clusters declaration enforce [this JSON schema](/schemas/openshift/cluster-1.yml).

OpenShift group association can be self-serviced via App-Interface.

Groups should be defined under the `managedGroups` section in the cluster file. This is a list of group names that are managed. To associate a user to a group, the user has to be associated to a role that has `access` to the OpenShift group.

An example of a role can be found [here](/data/teams/hive/roles/dev.yml).

### Manage OpenShift LimitRanges via App-Interface (`/openshift/limitrange-1.yml`)

This integration allows namespace owners to manage LimitRanges objects on their namespaces

To deploy and manage LimitRanges on a namespace, a user must add the following to a namespace declaration:

```yaml
limitRanges:
  $ref: /dependencies/openshift/limitranges/<some-name>.yml
```

The LimitRange limits can be customized by creating a new file and referencing the new file in the namespace declaration

The `/openshift/limitrange-1.yml` schema maps to the LimitRanges specs.

### Self-Service OpenShift ServiceAccount tokens via App-Interface (`/openshift/limitrange-1.yml`)

This integration allows namespace owners to get ServiceAccount tokens from a different cluster/namespace in to their namespace for consumption.

To add a Secret to a namespace, containing the token of a ServiceAccount from another namespace, a user must add the following to a namespace declaration:

```yaml
openshiftServiceAccountTokens:
- namespace:
    $ref: /services/<service>/namespaces/<namespace>.yml
  serviceAccountName: <serviceAccountName>
```

The integration will get the token belonging to that ServiceAccount and add it into a Secret called:
`<clusterName>-<namespaceName>-<ServiceAccountName>`.
The Secret will have a single key called `token`, containing a token of that ServiceAccount.

### Manage Vault configurations via App-Interface

https://vault.devshift.net is entirely managed via App-Interface and its configuration can be found in [config](/data/services/vault.devshift.net/config) folder of ` vault.devshift.net` service

#### Manage vault audit backends (`/vault-config/audit-1.yml`)
Audit devices are the components in Vault that keep a detailed log of all requests and response to Vault

Example:
```yaml
---
$schema: /vault-config/audit-1.yml

labels:
  service: vault.devshift.net

_path: "file/"
type: "file"
description: ""
options:
  _type: "file"
  file_path: "/var/log/vault/vault_audit.log"
  format: "json"
  log_raw: "false"
  hmac_accessor: "true"
  mode: "0600"
  prefix: ""
```
Current audit backends configurations can be found [here](/data/services/vault.devshift.net/config/audit-backends/)

For more information please see [vault audit backends documentation](https://www.vaultproject.io/docs/audit/index.html)

#### Manage vault auth backends (`/vault-config/auth-1.yml`)
Auth backends are the components in Vault that perform authentication and are responsible for assigning identity and a set of policies to a user.

Example:
```yaml
---
$schema: /vault-config/auth-1.yml

labels:
  service: vault.devshift.net

_path: "github/"
type: "github"
description: "github auth backend"
settings:
  config:
    _type: "github"
    organization: "app-sre"
    base_url: ""
    max_ttl: "360h"
    ttl: "120h"
policy_mappings:
  - github_team:
      $ref: <github team datafile (`/access/permission-1.yml`), for example: /dependencies/vault/permissions/app-sre.yml>
    policies:
      - $ref: <vault policy datafile (`/vault-config/policy-1.yml`), for example: /services/vault.devshift.net/config/policies/app-sre-policy.yml>
```
**Note**: some auth backends like github support policy mappings. Policy mapping can be applied to auth backed entity, for example in case with github auth currently allowed entity is a `team`.
To apply vault policy on auth entity `policy_mappings` key should be used.

Current auth backends configurations can be found [here](/data/services/vault.devshift.net/config/auth-backends)

For more information please see [vault auth backends documentation](https://www.vaultproject.io/docs/auth/index.html)

#### Manage vault policies (`/vault-config/policy-1.yml`)
Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault

Exmaple:
```yaml
---
$schema: /vault-config/policy-1.yml

labels:
  service: vault.devshift.net

name: "<POLICY_NAME>"
rules: |
  path "<SECRETS_ENGINE>/PATH/*" {
    capabilities = ["create","read","update","delete","list"]
  }
```
Current vault policies can be found [here](/data/services/vault.devshift.net/config/policies)

For more information please see [vault policies documentation](https://www.vaultproject.io/docs/concepts/policies.html)

For an example on adding team access to manage Vault app-interface secrets see [this PR](https://gitlab.cee.redhat.com/service/app-interface/merge_requests/2097).

#### Manage vault roles (`/vault-config/role-1.yml`)
Roles represents a set of Vault policies and login constraints that must be met to receive a token with those policies.
The scope can be as narrow or broad as desired. Role can be created for a particular machine, or even a particular user on that machine,
or a service spread across machines. The credentials required for successful login depend upon the constraints set on the Role associated with the credentials.
Currently we support only AppRole.

AppRole Example:
```yaml
---
$schema: /vault-config/role-1.yml

labels:
  service: vault.devshift.net

name: "<ROLE_NAME>"
type: "approle"
mount: "approle/"
options:
  _type: "approle"
  bind_secret_id: "true"
  local_secret_ids: "false"
  period: "0s"
  secret_id_num_uses: "0"
  secret_id_ttl: "0s"
  token_max_ttl: "30m"
  token_num_uses: "1"
  token_ttl: "30m"
  token_type: "default"
  bound_cidr_list: []
  policies:
    - <VAULT_POLICY>
  secret_id_bound_cidrs: []
  token_bound_cidrs: []
```
Current vault roles can be found [here](/data/services/vault.devshift.net/config/roles)

For more information please see [vault AppRole documentation](https://www.vaultproject.io/docs/auth/approle.html)

#### Manage vault secret-engines (`/vault-config/secret-engine-1.yml`)
Secrets engines are components which store, generate, or encrypt data. Secrets engines are incredibly flexible, so it is easiest to think about them in terms of their function.
Secrets engines are provided some set of data, they take some action on that data, and they return a result.

KV Secrets engine Example:
```yaml
---
$schema: /vault-config/secret-engine-1.yml

labels:
  service: vault.devshift.net

_path: "<SECRETS_ENGINE_MOUNT_PATH>"
type: "kv"
description: "new kv secrets engine"
options:
  _type: "kv"
  version: "2"
```
Current secrets engines can be found [here](/data/services/vault.devshift.net/config/secret-engines)

For more information please see [vault secrets engines documentation](https://www.vaultproject.io/docs/secrets/index.html)


### Manage AWS access via App-Interface (`/aws/group-1.yml`) using Terraform

[teams](/data/teams) contains all the teams that are being services by the App-SRE team. Inside of those directories, there is a `users` folder that lists all the `users` that are linked to that team. Each `user` has a list of assiciated `roles`. A `role` can be used to grant AWS access to a user, by adding the `user` to an AWS `group`.

Groups declaration enforce [this JSON schema](/schemas/aws/group-1.yml). Note that it contains a reference to the AWS account in which the group exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.
* A group without associated users will not be created.

#### Manage AWS users via App-Interface (`/aws/group-1.yml`) using Terraform

AWS users can be entirely self-serviced via App-Interface.

In order to get access to an AWS account, a user has to have:
* A public binary GPG key, which will be used to encrypt the generated password to send by mail.
* A `role` that includes (at least) one of the following:
  * An `aws_groups` section, with a reference to an AWS group file.
    * Example: [sre-aws](/data/teams/app-sre/roles/app-sre.yml) role.
  * A `user_policies` section, with a reference to a policy json document.
    * Example: [f8a-dev-osio-dev.yml](/data/teams/devtools/roles/f8a-dev-osio-dev.yml)
    * Supported terraform-like templates (will be replaced with correct values at run time):
      * `${aws:accountid}`
      * `${aws:username}`

Once a user is created, an email invitation to join the account will be sent with all relevant information.

#### Adding your public GPG key

A base64 encoded binary GPG key should be added to the user file, under the `public_gpg_key` parameter.

To export your key:
```
gpg --export <redhat_username>@redhat.com | base64
```

To get your base64 encoded binary GPG key from an [ascii armored output](https://www.gnupg.org/gph/en/manual/x56.html):
```
cat <redhat_username>.gpg.asc | gpg --dearmor | base64
```

To test if your binary base64 encoded GPG key in MR is good You may put part of MR containing key to some file (f.e. FILENAME) and use command:
```
cat FILENAME | sed -e 's/\ //g'| base64 -d | gpg
```

Example: https://gitlab.cee.redhat.com/service/app-interface/blob/f40e0f27eacf5510a954c034292e937632caecc7/data/teams/app-sre/users/jmelisba.yml#L27


### Manage AWS resources via App-Interface (`/openshift/namespace-1.yml`) using Terraform

[services](/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.
* To be able to use this feature, the `managedTerraformResources` field must exist and equal to `true`.

#### Manage RDS databases via App-Interface (`/openshift/namespace-1.yml`)

RDS instances can be entirely self-serviced via App-Interface.

In order to add or update an RDS database, you need to add them to the `terraformResources` field.

- `provider`: must be `rds`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
- `parameter_group`: (optional) path relative to [resources](/resources) to a file with parameter group values. Note that it starts with `/`.
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `engine: mysql`.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-instance" and `provider` "rds", the created Secret will be called `my-instance-rds`.

Once the changes are merged, the RDS instance will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `db.host` - The hostname of the RDS instance.
- `db.port` - The database port.
- `db.name` - The database name.
- `db.user` - The master username for the database.
- `db.password` - Password for the master DB user.

#### Manage S3 buckets via App-Interface (`/openshift/namespace-1.yml`)

S3 buckets can be entirely self-serviced via App-Interface.

In order to add or update an S3 bucket, you need to add them to the `terraformResources` field.

- `provider`: must be `s3`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `acl: public`.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-bucket" and `provider` "s3", the created Secret will be called `my-bucket-s3`.

Once the changes are merged, the S3 bucket will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `bucket` - The name of the bucket.
- `aws_region` - The name of the bucket's AWS region.
- `endpoint` - The url of the region's S3 endpoint.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage ElastiCache databases via App-Interface (`/openshift/namespace-1.yml`)

ElastiCache (HA) clusters can be entirely self-serviced via App-Interface.

In order to add or update an ElastiCache database, you need to add them to the `terraformResources` field.

- `provider`: must be `elasticache`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
- `parameter_group`: (optional) path relative to [resources](/resources) to a file with parameter group values. Note that it starts with `/`.
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `engine_version: 5.0.3`.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-cluster" and `provider` "elasticache", the created Secret will be called `my-cluster-elasticache`.

Once the changes are merged, the ElastiCache clusters will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `db.endpoint` - The configuration endpoint of the ElastiCache cluster.
- `db.port` - The database port.
- `db.auth_token` - Authentication token for the configuration endpoint.

#### Manage Service account IAM Users via App-Interface (`/openshift/namespace-1.yml`)

IAM users to be used as service accounts can be entirely self-serviced via App-Interface.

In order to add or update a service account, you need to add them to the `terraformResources` field.

- `provider`: must be `service-account`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier`: name of resource to create (or update)
- `variables`: list of key-value pairs to use for templating of `user_policy`. these pairs will also be added to the output resource.
- `policies`: list of AWS policies you wish to attach to the service account user.
- `user_policy`: an AWS user policy to create and attach to the service account user.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-user" and `provider` "service-account", the created Secret will be called `my-user-service-account`.

Once the changes are merged, the IAM resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

In addition, any additional key-value pairs defined under `variables` will be added to the Secret.

#### Manage SQS queues via App-Interface (`/openshift/namespace-1.yml`)

SQS queues can be entirely self-serviced via App-Interface.

In order to add or update an SQS queue, you need to add them to the `terraformResources` field.

- `provider`: must be `sqs`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - a name of the group of resources to create (or update)
  - Does not affect names of queues.
  - Will be used as the name of the IAM user that will be created.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-queue" and `provider` "sqs", the created Secret will be called `my-queue-sqs`.
- `specs`: list of queue specifications to create:
  - `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
  - `queues`: list of queues to create according to the defined defaults:
    - `key` is the key to be added to the Secret
    - `value` is the name of the table to create

Once the changes are merged, the SQS queue will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `aws_region` - The name of the queue's AWS region.

In addition, for each queue defined under `queues`, a key will be created and will contain the queue url. The key is the value defined in `key`.

#### Manage DynamoDB tables via App-Interface (`/openshift/namespace-1.yml`)

DynamoDB tables can be entirely self-serviced via App-Interface.

In order to add or update a DynamoDB table, you need to add them to the `terraformResources` field.

- `provider`: must be `dynamodb`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - a name of the group of resources to create (or update)
  - Does not affect names of tables.
  - Will be used as the name of the IAM user that will be created.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-table" and `provider` "dynamodb", the created Secret will be called `my-table-dynamodb`.
- `specs`: list of table specifications to create:
  - `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
  - `tables`: list of tables to create according to the defined defaults:
    - `key` is the key to be added to the Secret
    - `value` is the name of the table to create

Once the changes are merged, the DynamoDB table will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `aws_region` - The name of the queue's AWS region.
- `endpoint` - The DynamoDB endpoint URL.

In addition, for each table defined under `tables`, a key will be created and will contain the table name. The key is the value defined in `key`.

#### Manage ECR repositories via App-Interface (`/openshift/namespace-1.yml`)

ECR repositories can be entirely self-serviced via App-Interface.

In order to add or update an ECR repository, you need to add them to the `terraformResources` field.

- `provider`: must be `ecr`
- `account`: must be one of the AWS account names we manage. Current options:
  - `quayio-stage`
- `identifier` - name of resource to create (or update)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-repo" and `provider` "ecr", the created Secret will be called `my-repo-ecr`.

Once the changes are merged, the ECR repository will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `url` - The url of the repository.
- `aws_region` - The name of the repository's AWS region.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage stacks of S3 bucket and CloudFront distribution via App-Interface (`/openshift/namespace-1.yml`)

Stacks of an S3 bucket with a CloudFront distribution can be entirely self-serviced via App-Interface.

In order to add or update an S3+CloudFront stack, you need to add them to the `terraformResources` field.

- `provider`: must be `s3-cloudrfont`
- `account`: must be one of the AWS account names we manage. Current options:
  - `quayio-stage`
  - `quayio-prod`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-s3-cf-stack" and `provider` "s3-cloudfront", the created Secret will be called `my-s3-cf-stack-s3-cloudfront`.

Once the changes are merged, the resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `bucket` - The name of the bucket.
- `aws_region` - The name of the bucket's AWS region.
- `endpoint` - The url of the region's S3 endpoint.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `cloud_front_origin_access_identity_id` - The identifier for the distribution.
- `s3_canonical_user_id` - The Amazon S3 canonical user ID for the origin access identity.
- `distribution_domain` - The domain name corresponding to the distribution.
- `origin_access_identity` - The origin access identity in the form of `origin-access-identity/cloudfront/<cloud_front_origin_access_identity_id>`.

### Manage Slack User groups via App-Interface

Slack User groups can be self-services via App-Interface.

To manage a User group via App-Interface:

1. Add a `permission` file with the following details:

- `name`: name for the permission
- `description`: description of the User group (currently not automated)
- `service`: `slack-usergroup`
- `handle`: the handle of the User group
- `workspace`: a reference to a file representing the Slack Workspace
- `pagerduty`: a reference to a file representing a PagerDuty target (Schedule or Escalation Policy).
  * Adding this attribute will add the PagerDuty target as an additional "source of truth", and will add the final schedule user to the Slack user group (in addition to any references from user files).
- `github_owners`: a list of urls of raw github OWNERS files to extract `approvers` from
- `channels`: a list of channels to add to the User group

2. Add this permission to the desired `roles`, or create a new `role` with this permission only (mandatory).

Examples:
* An example for the `app-sre-team` User group permission can be found [here](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml)
* An example for a role that has this permission can be found [here](/data/teams/app-sre/roles/app-sre.yml)
* An example for the `app-sre-ic` User group permission which is also synced with a PagerDuty schedule can be found [here](/data/teams/app-sre/permissions/app-sre-ic-coreos-slack.yml)
* An example for a PagerDuty schedule file can be found [here](/data/dependencies/pagerduty/app-sre-primary.yml).
* An example for a PagerDuty escalation policy file can be found [here](/data/dependencies/pagerduty/app-sre-escalation-policy.yml).
* An example for a GitHub OWNERS file can be found [here](/data/teams/sd-sre/permissions/aws-account-operator-coreos-slack.yml).

Notes:
* Creating new User groups is not supported (User group has to pre-exist).
* In order to be able to use the `pagerduty` attribute of a `permission`, the relevant users (ones from that PagerDuty schedule) should have the following attributes in their user files:
  * `slack_username` - if it is different from `org_username`
  * `pagerduty_name` - if it is different from `name`

### Manage Jenkins jobs configurations using jenkins-jobs

Jenkins jobs configurations can be entirely self-serviced via App-Interface, and allows to define JJB Manifests to be used to bring up CI/CD/Automation pipelines or adhoc jobs in the internal and external Jenkins instance.

Note: This used to be managed in the [JJB](https://gitlab.cee.redhat.com/service/jjb) repository.

To add a configuration to a Jenkins instance, add a `jenkins-config` object with the following details:
- `instance` - reference to a jenkins instance
- `type` - one of the following JJB entities:
  - `views`
  - `secrets`
  - `base-templates`
  - `job-templates`
  - `jobs`
- `config` - a list of configurations of type `view` or `project` (use `config` for `views` and `jobs` types)
- `config_path` - a path to a resource containing configuration (use `config_path` for `secrets` and `job-templates` types, which tend to be have a "complex" yaml)

Examples:
- `views` - [object](/data/services/app-interface/cicd/ci-int/views.yaml)
- `secrets` - [object](/data/services/app-interface/cicd/ci-int/secrets.yaml), [resource](/resources/jenkins/app-interface/secrets.yaml)
- `job-templates` - [object](/data/services/app-interface/cicd/ci-int/job-templates.yaml), [resource](/resources/jenkins/app-interface/jobs-templates.yaml)
- `jobs` - [object](/data/services/app-interface/cicd/ci-int/jobs.yaml)

All JJB configurations rely on a set of JJB entities for the corresponding Jenkins intance:
- `global` - [resources](/resources/jenkins/common/)
- `ci-int` - [object](/data/services/jenkins/cicd/ci-int/), [resources](/resources/jenkins/ci-int/)
- `ci-ext` - [object](/data/services/jenkins/cicd/ci-ext/), [resources](/resources/jenkins/ci-ext/)
- `ci-centos` - [object](/data/services/jenkins/cicd/ci-centos/), [resources](/resources/jenkins/ci-centos/)

The final JJB configrations will be sorted in the following order:
- `defaults`
- `global-defaults`
- `views`
- `secrets`
- `base-templates`
- `global-base-templates`
- `job-templates`
- `jobs`

External reference:
- [Jenkins Job Builder](https://docs.openstack.org/infra/jenkins-job-builder/)

Notes:
- To use a KV v1 secret engine in a secret, the `secret-path` should be `<secret_engine>/<path_to_secret>`.
- To use a KV v2 secret engine in a secret, the `secret-path` should be `<secret_engine>/data/<path_to_secret>`.


### Delete AWS IAM access keys via App-Interface

AWS IAM keys deletion can be entirely self-serviced via App-Interface.

In order to delete a key from an AWS account, add the Access key ID to the `deleteKeys` list in the AWS Account file.
For example, merging [this](/data/aws/osio/account.yml#L11) line will delete the Access key with ID `AKIAVT6AWJBAILFXBV4A` from the `osio` account.

One use case this is useful for is leaked keys.


### AWS garbage collection

AWS resources which do *NOT* have one of the following properties are continuously garbage collected:

* The resource name starts with the name of an existing IAM user
* The resource name has `stage` or `prod` in it
* The resource has one of these tags:
  * `managed_by_integration` - resources managed by the `terraform-resources` or `terraform-users` integrations
  * `owner` - resources managed by `app-sre` team terraform configurations in [housekeeping](https://gitlab.cee.redhat.com/dtsd/housekeeping/tree/master/terraform)
  * `aws_gc_hands_off` - resources created manually, if tag is set to `true`
  * `ENV`/`environment` - resources which are related to `stage` or `prod`

Supported resource types are:
* S3
* SQS
* RDS
* DynamoDB

Notes:
* This integration does not actually delete resources currently (disabled by default), but it will still list resources that would have otherwise been deleted in every PR check.

### GitHub user profile compliance

App-Interface users must define a `github_username` field in their user file. This profile must comply with the following requirements:

* The profile `Company` field must contain `Red Hat` (regex expression: `^.*[Rr]ed ?[Hh]at.*$`)

### Manage GitLab group members

Adding, removing, and changing access levels of gitlab group members can be self-serviced via App-Interface

To manage a GitLab group via App-Interface:
1. Add a `permission` file with the following details:

- `name`: name for the permission
- `description`: description
- `service`: `gitlab-group-membership`
- `group`: name of GitLab Group
- `access`: access level this permission gives (owner/maintainer/developer/reporter/guest)

2. Add this permission to the desired `roles`, or create a new `role` with this permission only.

3. Add this permission to the GitLab bot role which can be found [here](/data/teams/app-sre/roles/app-sre-gitlab-bot.yml)

4. Make sure that ever member of the group has a role giving them permission to the group otherwise the integration will remove them.

Examples:
* An example for the `app-sre` group permission can be found [here](/data/dependencies/gitlab/permissions/app-sre-member.yml)
* An example for a role that has this permission can be found [here](/data/teams/app-sre/roles/app-sre.yml)

Notes:
* Creating new GitLab groups is not supported (GitLab group has to pre-exist).


### Create GitLab projects

Creating a new project in gitlab can be self-serviced via App-Interface.

To request the creation of a new project, submit a PR adding the new project under the desired group [here](/data/dependencies/gitlab/gitlab.yml). The project will be created on merge.

To get access to the project, if required, contact the App SRE team.


### Add a Grafana Dashboard

1. Open the Playground dashboard and follow the documentation there.

2. Export the graph from Grafana as JSON

3. Add the graph json to `/resources/observability/grafana/`. Please follow the naming convention

4. Add the graph to the resources list at `/data/services/observability/namespaces/app-sre-observability-ENV.yml` (ENV being either production or stage)

5. Wait for the configmap has been merged and applied to the cluster(s)

6. Add the configmap as a volume and volumeMount to the grafana pod template in [the app-sre-observability repo](https://gitlab.cee.redhat.com/service/app-sre-observability/). An example of the changes can be found [here](https://gitlab.cee.redhat.com/service/app-sre-observability/commit/0bee8c95be4a27121e6b1ff82a75a2e01901a8f4)

7. Once the template changes are merged, the saas-repo hash for the grafana service need to be bumped so the changes are deployed. This can be done on [the saas-app-sre-observability repo](https://gitlab.cee.redhat.com/service/saas-app-sre-observability/)

### Execute a SQL Query on an App Interface controlled RDS instance

To execute an SQL Query, you you have to commit to the app-interface an YAML
file with the following content:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
name: <sql query unique name>
namespace:
  $ref: /services/<service>/namespaces/<namespace>.yml
identifier: <RDS resource identifier (same as defined in the namespace)>
output: <filesystem or stdout>
query: <sql query>
```

Example:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
labels: {}
name: 2020-01-30-account-manager-registries-stage
namespace:
  $ref: /services/uhc/namespaces/uhc-stage.yml
identifier: uhc-acct-mngr-staging
output: filesystem
query: |
  SELECT id, name, deleted_at from registries;
```

When that SQL Query specification is merged, the integration will create a
Job in the namespace provided:

```bash
$ oc get pods | grep 2020-01-30-account-manager-registries-stage
2020-01-30-account-manager-registries-stage-7pl6v              0/1     Completed   0          4h32m
```

That Job will execute the SQL query and place the result to the requested
location:

- `stdout`: the pod created by the Job will have the SQL query result printed
  to the stdout. Example:

```bash
$ oc logs 2020-01-28-account-manager-registries-stage-7pl6v
             id              |            name             |          deleted_at
-----------------------------+-----------------------------+-------------------------------
 1HPiQ7VattP4WXgGRMvANMIxAuJ | registry.redhat.io          |
 1HPgUBbu7A5ATEa9pVgderCnaBw | registry.connect.redhat.com |
 1Aabcdoseqrawn1t994qf3ny3ec | quay.io                     |
 1VTLMg1uEFgznKiLVh7szZHQcnU | aaa                         | 2019-12-25 11:08:22.886628+00
 1VTMLJRMxUMjOLYczcmPU7GKnZN | aaa                         | 2019-12-25 11:18:12.000539+00
 1VTMJoJgSGW6EnuwsxLrrstdB7k | aaa                         | 2020-01-13 08:24:12.635462+00
 1VTMKAJ9orhfiB5Us7VQSobmjfW | aaa                         | 2020-01-13 08:24:25.324837+00
 1VTMKSKYsDPugCUFKhdg91PMVpL | aaa                         | 2020-01-13 08:24:37.888744+00
 1VTMKZvvoazsHM8Qt58bLsOD8Yk | aaa                         | 2020-01-13 08:25:31.468072+00
 1VTMKj0RZU4VflvpWFabCkq14ji | aaa                         | 2020-01-13 08:26:03.942181+00
 1VTMKyagkV8EqDBAQPyoWuv1cmI | aaa                         | 2020-01-13 08:26:14.51152+00
 1VTML5RK1eqsWKZAke0fC3FEgWY | aaa                         | 2020-01-13 08:26:28.173743+00
 1VTN6U2ClGNWn3uAqBSUkaZ8DGJ | aaa                         | 2020-01-13 08:26:36.128141+00
 1VVB7O0E9GqJ9tJJJ8Cz34mbCfd | aaa                         | 2020-01-13 08:26:50.414377+00
 1VVB7nTNwEABvhhrY7bAEoUysLW | aaa                         | 2020-01-13 08:26:58.086477+00
 1VVB7q4PPEH3R1tsuPTLjabYqId | aaa                         | 2020-01-13 08:27:12.184195+00
 1VVBSyT1eblnOXm5fsQirKdzHxu | aaa                         | 2020-01-13 08:27:20.478724+00
 1VVBUGCglzmE98l9zLeqljWKZdV | aaa                         | 2020-01-13 08:27:34.340959+00
 1VVBUV6rcZ9jsqo2vUuBpw21gbP | aaa                         | 2020-01-13 08:27:41.733607+00
(19 rows)
```

- `filesystem`: the pod created by the Job will have the SQL query result
  written to the pod filesystem. In the pod stdout you will see the `oc`
  command to retrieve the SQL query results.

```bash
$ oc logs 2020-01-30-account-manager-registries-stage-cjh82
Get the sql-query results with:

oc rsh --shell=/bin/bash 2020-01-30-account-manager-registries-stage-cjh82 cat /tmp/query-result.txt

Sleeping 3600s...
```

Notice that, in this case, the pod will be kept sleeping for 1 hour so you can
retrieve the query results.

Using that command:

```bash
$ oc rsh --shell=/bin/bash 2020-01-30-account-manager-registries-stage-cjh82 cat /tmp/query-result.txt
             id              |            name             |          deleted_at
-----------------------------+-----------------------------+-------------------------------
 1HPiQ7VattP4WXgGRMvANMIxAuJ | registry.redhat.io          |
 1HPgUBbu7A5ATEa9pVgderCnaBw | registry.connect.redhat.com |
 1Aabcdoseqrawn1t994qf3ny3ec | quay.io                     |
 1VTLMg1uEFgznKiLVh7szZHQcnU | aaa                         | 2019-12-25 11:08:22.886628+00
 1VTMLJRMxUMjOLYczcmPU7GKnZN | aaa                         | 2019-12-25 11:18:12.000539+00
 1VTMJoJgSGW6EnuwsxLrrstdB7k | aaa                         | 2020-01-13 08:24:12.635462+00
 1VTMKAJ9orhfiB5Us7VQSobmjfW | aaa                         | 2020-01-13 08:24:25.324837+00
 1VTMKSKYsDPugCUFKhdg91PMVpL | aaa                         | 2020-01-13 08:24:37.888744+00
 1VTMKZvvoazsHM8Qt58bLsOD8Yk | aaa                         | 2020-01-13 08:25:31.468072+00
 1VTMKj0RZU4VflvpWFabCkq14ji | aaa                         | 2020-01-13 08:26:03.942181+00
 1VTMKyagkV8EqDBAQPyoWuv1cmI | aaa                         | 2020-01-13 08:26:14.51152+00
 1VTML5RK1eqsWKZAke0fC3FEgWY | aaa                         | 2020-01-13 08:26:28.173743+00
 1VTN6U2ClGNWn3uAqBSUkaZ8DGJ | aaa                         | 2020-01-13 08:26:36.128141+00
 1VVB7O0E9GqJ9tJJJ8Cz34mbCfd | aaa                         | 2020-01-13 08:26:50.414377+00
 1VVB7nTNwEABvhhrY7bAEoUysLW | aaa                         | 2020-01-13 08:26:58.086477+00
 1VVB7q4PPEH3R1tsuPTLjabYqId | aaa                         | 2020-01-13 08:27:12.184195+00
 1VVBSyT1eblnOXm5fsQirKdzHxu | aaa                         | 2020-01-13 08:27:20.478724+00
 1VVBUGCglzmE98l9zLeqljWKZdV | aaa                         | 2020-01-13 08:27:34.340959+00
 1VVBUV6rcZ9jsqo2vUuBpw21gbP | aaa                         | 2020-01-13 08:27:41.733607+00
(19 rows)
```

Each Job will be automatically deleted after 7 days.

## Design

Additional design information: [here](docs/app-interface/design.md).

[schemas]: </schemas>
[userschema]: </schemas/access/user-1.yml>
[crossref]: </schemas/common-1.json#L58-L86>
[role]: </schemas/access/role-1.yml>
[permission]: </schemas/access/permission-1.yml>

## Developer Guide

More information [here](docs/app-interface/developer.md).
