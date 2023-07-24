# Unleash Deployment

- [Tenant Request](#tenant-request)
- [Architecture](#architecture)
- [Naming Conventions](#naming-conventions)
- [Red Hat SSO](#red-hat-sso)
- [Namespace](#namespace)
- [Configuration Secret](#configuration-secret)
- [Client Access Token Secret](#client-access-token-secret)
- [Database](#database)
- [Deployment](#deployment)
- [Examples](#examples)
  - [Jira ticket requesting Unleash instances:](#jira-ticket-requesting-unleash-instances)
  - [Message to requester after deployment:](#message-to-requester-after-deployment)
  - [Full featured Unleash instances](#full-featured-unleash-instances)
  - [Example SSO SNOW ticket](#example-sso-snow-ticket)

## Tenant Request
Tenants will request an instance of Unleash following the
[steps here](https://gitlab.cee.redhat.com/service/dev-guidelines/-/blob/master/content/en/docs/AppSRE/Advanced/feature-toggles.md).

This document describes how to deploy the requested instance using App
Interface.

## Architecture

Unleash is deployed as a regular Service/Deployment to the `unleash` Namespace
in the OpenShift Cluster. It consumes three Secrets:

- [Tenant Request](#tenant-request)
- [Architecture](#architecture)
- [Naming Conventions](#naming-conventions)
- [Red Hat SSO](#red-hat-sso)
- [Namespace](#namespace)
- [Configuration Secret](#configuration-secret)
- [Client Access Token Secret](#client-access-token-secret)
- [Database](#database)
- [Deployment](#deployment)
- [Examples](#examples)
  - [Jira ticket requesting Unleash instances:](#jira-ticket-requesting-unleash-instances)
  - [Message to requester after deployment:](#message-to-requester-after-deployment)
  - [Full featured Unleash instances](#full-featured-unleash-instances)
  - [Example SSO SNOW ticket](#example-sso-snow-ticket)

![](images/arch.png)

Clients can access Unleash using the Web UI (protected by [Red Hat SSO](#red-hat-sso)),
or via client API, using the [Client Access Token Secret](#client-access-token-secret).



## Naming Conventions

Considering that the Unleash instance will be created in the `unleash` Namespace and
consumed by a given application, the naming convention used throughout
this document will always relate the Unleash instance to the application. Some
examples:

- `path: <secret>/unleash/<application-name>-config`
- `output_resource_name: <application-name>-unleash-rds`
- `path: <secret>/unleash/<application-name>-unleash-token`

This convention allows the Unleash Namespace of a given Cluster to have
multiple Unleash instances, each serving different applications running on the
same Cluster.

Similarly, the URL for the Unleash instance will be:

```
https://<application-name>.unleash.devshift.net
```

## Red Hat SSO

The Web UI authentication is done via Red Hat SSO (auth.redhat.com), and
the authorization relies on Rover groups.

Unleash supports three types of [user roles](https://docs.getunleash.io/reference/rbac):
* **Admin**
* **Editor**
* **Viewer**

Request a new SSO client for the Unleash instance via [ServiceNow ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=33995e691b4809587f9bfc8f034bcb2e). Fill in the following details:
* **Requested for**: Your name
* **Is this SSO enablement for a vendor?**: No
* **Please select the Application Name**: App-SRE Auth
* **Business Owner**: Your name
* **Authentication initial URL**: `https://<application-name>.unleash.devshift.net`
* **Technical Point-of-Contact**: Your name
* **Client ID / Entity ID**: `unleash-<application-name>`
* **Primary Identifier Key**: Username
* **User Attributes**: Beside default attributes (name, email, preferred_username), add CN of all user LDAP groups as "roles" attribute
* **SSO Protocol**: OIDC (OpenID Connect)
* **What environments are you interested in using for SSO?**: Production
* **Flow Uses**: Authorization Code
* **Access Type**: Confidential
* **Redirect Urls**: `https://<application-name>.unleash.devshift.net/*`

You may add a comment to the ticket and mention `unleash-app-interface-prod` as a reference implementation. See [SNOW ticket for app-interface-prod](https://redhat.service-now.com/help?id=rh_ticket&is_new_order=true&table=sc_request&sys_id=1a3c4d0b1b3fedd0532233fccd4bcb15) as an example.


After receiving the SSO client, you have to create the
[Configuration Secret](#configuration-secret) described ahead.

## Namespace

All the Unleash instances are deployed to a dedicated `unleash` Namespace. The
Cluster will be chosen by the AppSRE Team, according to application consuming
the instance.

The `app-sre-prod-01` already has an `unleash` Namespace. If you're going to
create the new Unleash instance in that Namespace, you can skip this section.

To create the Unleash namespace in a given Cluster, add the Namespace
manifest `<cluster-name>.yml` to the
[namespaces directory](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/unleash/namespaces)
of the Unleash service.

The Namespace manifest will initially contain:

```yaml
---
$schema: /openshift/namespace-1.yml

labels: {}

name: unleash
description: namespace for unleash

cluster:
  $ref: /openshift/<cluster>/cluster.yml

app:
  $ref: /services/unleash/app.yml

managedExternalResources: true
```

Replace `<cluster>` with the directory to the cluster configuration.

**NOTE:** More settings will be included to this Namespace in the next
sections.

## Configuration Secret

The Unleash instance expects an OpenShift Secret in the Namespace containing
the following data:

- `KC_HOST`: The SSO issuer url - `https://auth.redhat.com/auth`.
- `KC_REALM`: The used realm - `EmployeeIDP`.
- `KC_CLIENT_ID`: The SSO client ID from the SNOW ticket (`unleash-<application-name>`).
- `KC_CLIENT_SECRET`: The SSO client secret provided by the RHIT via SNOW ticket.
- `ADMIN_ACCESS_TOKEN`: The Bearer token to access the Unleash Admin API
  directly. We recommend using the bash command `uuidgen` to generate the
  token.
- `SESSION_SECRET`: The secret to secure the client session. We recommend
  using the bash command `uuidgen` to generate the secret.

Go to the Unleash
[Vault secret](https://vault.devshift.net/ui/vault/secrets/app-sre/list/unleash/)
and create a secret called `<application-name>-config`.

Then add it to the `unleash` Namespace:

```yaml
openshiftResources:
...
- provider: vault-secret
  path: app-sre/unleash/<application-name>-config
  version: 1
```

## Client Access Token Secret

The Client Access Token is also required by the Unleash instance, but it lives
in a different Secret so it can be exposed to the tenant's application
Namespace.

Only one key is expected in this Secret:

- `CLIENT_ACCESS_TOKEN`: The Bearer token to access the Unleash Client API
  directly. We recommend using the bash command `uuidgen` to generate the
  token.

Go to the Unleash
[Vault secret](https://vault.devshift.net/ui/vault/secrets/app-sre/list/unleash/)
and create a secret called `<application-name>-unleash-token`.

Then add it to the `unleash` Namespace:

```yaml
openshiftResources:
...
- provider: vault-secret
  path: app-sre/unleash/<application-name>-unleash-token
  version: 1
```

**IMPORTANT:** Make sure to add the `vault-secret` resource also to the
Namespace of the application consuming the Unleash instance (tenants are
expected to inform the application Namespace in the JIRA ticket).

## Database

Each instance of Unleash requires an independent PostgreSQL Database. To create
one, add this section to the Unleash Namespace:

```yaml
externalResources:
...
- provider: aws
  provisioner:
    $ref: /aws/<aws-account>/account.yml
  resources:
  - provider: rds
    identifier: <unique-rds-identifier>
    defaults: /terraform/resources/unleash/rds-1.yml
    output_resource_name: <application-name>-unleash-rds
```

## Deployment

To deploy the new instance to the `unleash` Namespace, add this section to the list of `targets` in [saas-unleash](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/unleash/cicd/saas-unleash.yaml) file:

```yaml
  - namespace:
      $ref: /services/unleash/namespaces/<application-name>-unleash.yml
    ref: <commit-hash>
    parameters:
      identifier: <application-name>
      configSecret: <application-name>-config
      databaseSecret: <application-name>-unleash-rds
      tokenSecret: <application-name>-unleash-token
      host: <full_qualified_host_name>
      admin_roles: <comma separated list of rover group names>
      editor_roles: <comma separated list of rover group names>
      viewer_roles: <comma separated list of rover group names>
```

That will create the Unleash Deployment, Route, and Service in the Namespace using the
Unleash version pin-pointed by the `<commit-hash>`.

Parameters:
- `identifier`: The application name, used to name the Deployment and the
  Service.
- `configSecret`: The configuration secret name as defined in the
  [Configuration Secret](#configuration-secret) section.
- `databaseSecret`: The `output_resource_name` as defined in the
  [Database](#database) section.
- `tokenSecret`: The token secret name as defined in the
  [Client Access Token Secret](#client-access-token-secret) section.
- `host`: The full qualified hostname of the `Route` spec shall be
  `<application-name>.unleash.devshift.net`. You have to arrange to get that
  sub-domain created.
- `admin_roles`: A comma-separated list of Rover group names to be used to
 grant the admin Unleash role.
  sub-domain created.
- `editor_roles`: A comma-separated list of Rover group names to be used to
 grant the editor Unleash role.
  sub-domain created.
- `viewer_roles`: A comma-separated list of Rover group names to be used to
 grant the viewer Unleash role.

[Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/unleash/cicd/saas-unleash.yaml).


## Examples

### Jira ticket requesting Unleash instances:

[https://issues.redhat.com/browse/APPSRE-1801](https://issues.redhat.com/browse/APPSRE-1801)

### Message to requester after deployment:

```
The <application>'s Unleash instance is ready to be used.

Here's the documentation on how to consume it:
https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/feature-toggles/#consuming-unleash

The OpenShift Secret containing the CLIENT_ACCESS_TOKEN is called
<application>-unleash-token and it is already available in the <application>
Namespace.

The Web UI / REST API endpoint is:
https://<application>.unleash.devshift.net/
```

### Full featured Unleash instances

[https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/unleash/cicd/saas-unleash.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/unleash/cicd/saas-unleash.yaml)

### Example SSO SNOW ticket

[SNOW ticket for app-interface-prod](https://redhat.service-now.com/help?id=rh_ticket&is_new_order=true&table=sc_request&sys_id=1a3c4d0b1b3fedd0532233fccd4bcb15)
