# Design doc: LDAP group management

[toc]

## Author/date

Christian Assing / July 2023

## Tracking JIRA

[APPSRE-8037 - ldap group management](https://issues.redhat.com/browse/APPSRE-8037)

## Problem Statement

App-Interface allows tenants to conveniently manage user permissions and roles and use them in several services, e.g., Slack, Vault, or Glitchtip. However, to use those settings, a dedicated qontract-reconcile integration is needed that syncs the permissions/roles to the application (e.g., `glitchtip-projects`), but this can't be done if an application doesn't persist permissions and roles (e.g., [Unleash](https://www.getunleash.io/)).

A widespread authorization pattern used by applications is to use LDAP groups. Such groups can be either consumed via LDAP directly or via `realms.roles` attribute in Red Hat SSO access token.

Currently, tenants must manage LDAP groups outside of App-Interface, which is inconvenient and error-prone.

## Goals

Allow tenants to consume App-Interface roles (`$schema: /access/role-1.yml`) via LDAP groups.

## Nongoals

n/a

## Proposals

Enhance App-Interface roles schema (`$schema: /access/role-1.yml`) with an optional `ldap-group` attribute.

```yaml
---
$schema: /access/role-1.yml

labels: {}
name: app-sre

ldap-group: cn=app-sre,ou=app-interface,ou=groups,dc=redhat,dc=com
```

A dedicated `ldap-groups` attribute specifying the group in LDAP notation allows us to support multiple LDAP OUs and validation.

The specified LDAP group will be created if it doesn't exist and all users in a role will be added as members. The LDAP group shouldn't be managed outside App-Interface, e.g., via [Rover Groups](https://rover.redhat.com/groups/).

The sync details depend on ITIAM. Getting permissions on a dedicated LDAP `OU` for App-Interface is the best; this enables an easy reconciliation of the LDAP groups.

Unleash as an example:

![](images/unleash-example.png)

## Alternatives considered

n/a

## Resources

* [[unleash] RedHat SSO auth](https://issues.redhat.com/browse/APPSRE-7900)
* [SDE-2124 - [SRE Capability] Feature flags](https://issues.redhat.com/browse/SDE-3124)
* [LDAP User & Group Attributes](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/faq_ldap_user__group_attributes)
* [About LDAP Groups](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/specification_about_ldap_groups)
* [LDAP Service](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/specification_ldap_service)
## Milestones

1. Get approval and [an LDAP service account](https://issues.redhat.com/browse/ITIAM-5564) from ITIAM
1. Implement a qontract-reconcile integration that manages LDAP groups
