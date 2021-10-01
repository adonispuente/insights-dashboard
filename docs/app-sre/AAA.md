# Anthology of AppSRE Axioms

* Anthology: *a published collection of poems or other pieces of writing*
* Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*

## Index

<!-- TOC -->

- [Anthology of AppSRE Axioms](#anthology-of-appsre-axioms)
    - [Index](#index)
    - [Preface](#preface)
    - [Complementary Documentation and Resources](#complementary-documentation-and-resources)
    - [AppSRE Engineer Onboarding](#appsre-engineer-onboarding)
        - [Registering the user in App-Interface](#registering-the-user-in-app-interface)
        - [Access and Surfaces list](#access-and-surfaces-list)
            - [Returning Red Hat Employee Gotchas](#returning-red-hat-employee-gotchas)
            - [Maintaining access pieces](#maintaining-access-pieces)
        - [Knowledge Sharing and Training](#knowledge-sharing-and-training)
            - [Introduction](#introduction)
            - [Training Resources](#training-resources)
            - [Deep Dive sessions](#deep-dive-sessions)
            - [Practical Training Syllabus](#practical-training-syllabus)
    - [On call](#on-call)
    - [Incident Process](#incident-process)
        - [Generic Resources](#generic-resources)
    - [Contract](#contract)
        - [SRE Checkpoints](#sre-checkpoints)

<!-- /TOC -->

## Preface

This documents is for AppSRE engineer consumption.

It aims to ensure agreement and govern the AppSRE continuity and readiness plan.
Information within this document aims to be the authoritative source for access,
surfaces and processes, including incident management.

## Complementary Documentation and Resources

* [AppSRE Resources](https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction)
* [App-Interface](https://gitlab.cee.redhat.com/service/app-interface)
* [AppSRE Contract](https://gitlab.cee.redhat.com/app-sre/contract)
* [Developer's Guide](https://service.pages.redhat.com/dev-guidelines/)
* [Service Delivery / AppSRE shared
  drive](https://drive.google.com/drive/u/0/folders/1sQGfo57eU7UAKfbBy8LgwxhMdnzXc0KZ).
  Shared with Service Delivery.
* [AppSRE Team
  Drive](https://drive.google.com/drive/u/0/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs).
  Viewable and editable by AppSRE members only.

## AppSRE Engineer Onboarding

### Registering the user in App-Interface

Most of the resources required as an AppSRE will be obtained via a user definition with AppSRE specific roles in App-Interface.

* Developer's guide: [How to add a user to
  App-Interface](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/team/).
  [How to add
  roles](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/roles/).
* AppSRE engineers are located here:
  https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/teams/app-sre/users.
* [Generic documentation on how to add a
  user](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#add-or-modify-a-user-accessusers-1yml).
* Make sure your user file includes the `public_gpg_key` field.
  [Instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#adding-your-public-gpg-key).

### Access and Surfaces list

Every AppSRE/MT-SRE engineer should have access to the following:

* LDAP
  * If needed can reset KRB password
    [here](https://password.corp.redhat.com/changepassword).
  * https://gitlab.cee.redhat.com/app-sre/infra: keeps our Ansible and Terraform bits and bobs.
* Slack: coreos.slack.com
  * #sd-app-sre-teamchat (private channel): speak to any team member to get an
    invitation.
  * User groups: @app-sre-team: obtained via this
    [permission](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml).
* Internal IRC (irc.devel.redhat.com):
  * **#appsre**: backup channel if Slack is down or if sensitive content must be addressed.
  * **#servicedelivery**: backup channel for service delivery org if Slack is down.
  * **#MIM**: Major incident management.
  * **#aos**: Openshift channel.
* Calendar:
  * [AppSRE calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9iZ2VzaW1tYThyMTdndHJ2amxkaXU5Ym9ub0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE engineers are encourage to create all meetings in this calendar for team awareness.
  * [SD-org PTO / OOO](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    Any PTO must be reported here.
  * [SD-org calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE doesn't use this calendar usually.
* Google Meet:
  * App SRE bridge: https://meet.google.com/zti-gkvy-pvn. We refer to this room as [zti](https://meet.google.com/zti-gkvy-pvn).
* BlueJeans
  * To be used only if Google Meet is not available.
  * (Optional) Install BlueJeans client.
  * App SRE bridge: https://bluejeans.com/994349364/8531
* Mailing lists:
  * http://groups.google.com/: new mailing list manager
    * [sd-app-sre-announce](https://groups.google.com/u/0/a/redhat.com/g/sd-app-sre-announce)
    * [outage-list](https://groups.google.com/a/redhat.com/g/outage-list/about)
  * https://post-office.corp.redhat.com/mailman/listinfo: old mailing list central
    * ACCESS: sd-app-sre. Speak to @jonathan beakley.
    * ACCESS: sd-notifications. Subscribe from UI.
    * ACCESS: sd-org. Subscribe from UI.
    * ACCESS: sres. Subscribe from UI.
    * ACCESS: it-iam-announce-list. Subscribe from UI.
    * ACCESS: it-platform-community-list (useful for SSO). Subscribe from UI.
  * Optional - Additional information surfaces, subscription not mandatory
    * ACCESS: aos-devel: very high volume (useful to get the latest news about OpenShift development). Subscribe from UI.
* Sd-org onboarding
  * ACCESS Contact Meghna Gala (mgala@redhat.com) re Sd-org onboarding (may not be needed)
    * Added to sd-org mailing list
  * ACCESS: [Jira](https://issues.redhat.com)
    * Email openshift-jira-admin@redhat.com for any issues
    * Jira boards [Sprint Board](https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=5536) & [SD Epics](https://issues.redhat.com/projects/SDE)
* github.com/openshift
  * ACCESS: https://source.redhat.com/groups/public/atomicopenshift/atomicopenshift_wiki/openshift_onboarding_checklist_for_github
  * Ping [Bill Dettelback](https://rover.redhat.com/people/profile/bdettelb) on slack or mail for access to [quay github org](https://github.com/quay)
* Bugzilla
  * ACCESS: Ensure you have access to [bugzilla](https://bugzilla.redhat.com)
    * Login as Red Hat Associate with kerberos credentials
  * Verify you have permissions to view private and private_comment. This should be provided as part of the redhat group. See [here](https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=OMEGA&title=Group+Membership+Policy) for group information.
* Pagerduty
  * ACCESS: Create a [Jira ticket](https://issues.redhat.com/) in the OHSS board to request access to PagerDuty, and assign it to [Meghna Gala](https://rover.redhat.com/people/profile/mgala)
  * you can check this [example ticket](https://issues.redhat.com/browse/OHSS-2547), but double check the assignee before commiting.
  * Ensure you are listed with the appropriate contact detail in your Pagerduty profile.
  * The recommended setup includes the Pagerduty app on your mobile phone. From the website you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.
  * For notification troubleshooting see: https://support.pagerduty.com/docs/notification-troubleshooting
* AppSRE shared folders
  * ACCESS: Go to the following folders and request access with your Red Hat Gsuite account
    * [Public Top Level Directory](https://drive.google.com/drive/u/1/folders/1sQGfo57eU7UAKfbBy8LgwxhMdnzXc0KZ) (contains RCAs, etc)
    * [Private](https://drive.google.com/drive/u/1/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs) (for AppSRE Team members only)
* Vault
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
    * [setup instructions](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/adding-sensitive-data/#getting-access-to-vault)
* Quay
  * Login to/Create account at https://quay.io
    * Attach with Red Hat SSO.
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Add `quay_username` in the [user file](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams/app-sre/users) and populate with quay user.
* ssh access to jenkins related instances
  * Via MR to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all)
    * add username and public part of your ssh key like [here](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/144)

Every AppSRE engineer should have access to the following:

* GitHub
  * GitHub profile must include `Company: Red Hat`.
  * Verify inclusion in all github orgs listed
    [here](https://visual-app-interface.devshift.net/githuborgs).
* Gitlab:
  * https://gitlab.cee.redhat.com/app-sre
    * Access to all repositories is managed via this group.
    * Obtained via this [role](/data/teams/app-sre/roles/app-sre.yml).
  * https://gitlab.cee.redhat.com/service/app-interface
* AppSRE OCM org (https://console.redhat.com/openshift)
  * Access is [configured manually by an org administrator](/docs/app-sre/sop/ocm-appsre-org-access.md)
* AWS
  * Nothing to do. Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Make sure you enable MFA in **all** your AWS accounts.
* App SRE infrastructure managed by ansible
  * Access is managed by adding ssh keys to the [admin-list](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/hosts/group_vars/all#L4) and applying the `baseline` role to all hosts. It is recommended that ssh key is RSA, 4096-sized and password-protected as those are the [requirements for Tier 1 Bastion keys](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3#jive_content_id_Tier_1)
* OpenStack Project infrastructure
  * We have our ci-int infrastructure deployed [here](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project)
    * Domain: redhat.com
    * Kerberos login and password
  * Detailed info [here](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md)
* Tier 1 Bastion access for OSD3 (optional - mostly not needed):
  * This is necessary to access some clusters that are not publicly exposed (for example hive shards still in OSDv3)
  * Access process is documented [here](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3)
    * You should request Tier1
* Pendo:
  * This is necessary to post maintenance and outage messages in https://console.redhat.com/openshift
  * Access is provided via email to Allie Higgins <ahiggins@redhat.com>.
  * [Logging](https://app.pendo.io/login) in is done using the full Red Hat email.
* Unleash:
  * Feature toggle service to enable/disable features in runtime.
  * AppSRE unleash instance is here: https://app-interface.unleash.devshift.net/
  * More details available [here](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/unleash.md)
* SendGrid
  * Nothing to do, granted by `sendgrid_accounts` in the [AppSRE role](data/teams/app-sre/roles/app-sre.yml).
* Deadman's snitch
  * Ask somebody in the team to invite you to the organization. You'll receive an e-mail with a link to the invite. Create a new account then, it will be added automatically to the organization and you'll see all the heartbeats we have configured. You'll also be able to create even more.
* app-sre kube-configs: https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/

#### Returning Red Hat Employee Gotchas

* Accounts need to be re-enabled
  * Bugzilla
    * Send e-mail to bugzilla-owner@redhat.com or create ticket at the [Help
      Portal](https://help.redhat.com/)
    * It is likely the re-activated account will not have the needed
      permissions. Request access to the devel group by following the directions
      [here](https://docs.engineering.redhat.com/display/OMEGA/Group+Membership+Policy)
  * Bluejeans
    * Create an IT ticket

#### Maintaining access pieces

Access pieces are a very quickly moving target, and they change very frequently. In order to maintain an accurate list of access pieces these actions must be followed by the each AppSRE team member:

* All access pieces are documented in the [Access and surfaces list](#access-and-surfaces-list) section.
* If an AppSRE team member gains access to something and it's not linked from in this list, it's their responsibility to add it there.
* This list is actively reviewed by onboarding AppSRE members.

### Knowledge Sharing and Training

This section documents the specific processes related to knowledge sharing by
the AppSRE team in order to maintain a high level of accuracy and coverage of
all the knowledge within AppSRE.

#### Introduction

The purpose of this section is to document how knowledge is shared by the
AppSRE, both internally and externally.

Before diving into specific processes, it is important to state that the team
has a very clear mission with regard to knowledge sharing:

* There are no single owners or SMEs for any of the components and processes
  owned or implemented by the AppSRE team.
* It is the responsibility of every AppSRE member to make sure no knowledge is
  siloed, and to share any new knowledge piece with the rest of the team using
  the implemented processes and channels.
* Each AppSRE member has the right to raise any concerns about any knowledge
  gaps and the team will prioritize filling in those gaps.

#### Training Resources

The AppSRE team will maintains an index of training resources. All AppSRE members must go through those training documents:
https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction#jive_content_id_AppSRE_Training

#### Deep Dive sessions

On a periodical basis, the AppSRE team will hold "Deep Dive sessions". These sessions have the following characteristics:

* The main goal is to share knowledge within the AppSRE team.
* Periodicity: every 6 weeks.
* 1h sessions.
* Presentations should have an accompanying slide deck and must be well prepared.
* Any topics that are directly related to the AppSRE day-to-day will be prioritized over general knowledge ones.
* Attendance from all the team members is strongly encouraged, as well as participation and making the sessions dynamic.

Those sessions are tracked in this document: [AppSRE Deep Dives](https://docs.google.com/document/d/1T4QNO2qQYpBl4uhiNdr2iP7LO1pfmCVkzyWHgHDIIJA/edit).

Every AppSRE member that identifies any knowledge gaps in our documentation / resources has the responsibility of adding new proposals to the Deep Dives list of proposals.

#### Practical training Syllabus

Or: How to become a contributing AppSRE team member

This section guides a new team member in carrying out tasks that are:
- beneficial for the new team member
- beneficial for the team

As long as we can find tasks that match the learning criteria, we'll prefer to do them over doing an exercise task.

The assumption behind the structure of the syllabus is that there is a limited amount of information that is understood in every task, especially during the first period with the team. to have an experience in which the team member gets as much out of every task, we will want to make each task as narrow as possible. following tasks will assume the knowledge from previous tasks and expand around it. this essentially means that we are doing more [DFS than BFS](https://www.geeksforgeeks.org/difference-between-bfs-and-dfs).

Since every project, small or large, goes through app-interface in some way, the first few tasks will focus on day to day activities in app-interface, such as CI/CD and integrations. With this knowledge gained very early in the on-boarding process of a new team member, many requests in #sd-app-sre will already be understandable.

A big part of being an SRE is to work through toil items. We want to encourage new team members to contribute to refactors, cleanups, and any other toil item. We want to encourage everyone to do that! chop wood, carry water.

The practical training is a really a fancy name for working on tickets. Tickets to get started on are usually labeled as a `good-first-issue`, and some will contain an additional label `ai#n` to indicate the difficulty level:

[AI #1](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%231%22)
[AI #2](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%232%22)
[AI #3](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%233%22)
[AI #4](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%234%22)

Some of these tickets may be related to qontract-reconcile, which will require a development environment setup: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/app-sre/dev-setup.

## On call

Documented in the [On Call rotation](./on-call.md) SOP.

## Incident Process

All AppSRE team members will follow the Incident Process as accurately as possible, raise any concers and keep it up to date.

Documented in the [Incident Process](./incident-process.md) SOP.

### Generic Resources

* [PnT DevOps - Issue Escalation Procedure](https://docs.engineering.redhat.com/pages/viewpage.action?pageId=140541042)
* [Red Hat Major Incident Management (MIM)](https://source.redhat.com/groups/public/it-major-incident-management)
* [IT ISO (IT Operations)](https://source.redhat.com/groups/public/iso/it_operations_iso_wiki/welcome_to_it_iso_it_operations)

## Contract

AppSRE establishes a contract with the tenants. The contract is live here:
https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md

All Services must satisfy the list of ACs (Acceptance Criteria): [acs.html](https://app-sre.pages.redhat.com/contract/acs.html) and [acs.txt](https://app-sre.pages.redhat.com/contract/acs.txt)

The process for Service Onboarding is documented here:
https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/service/service_onboarding_flow.md

### SRE Checkpoints

All Services will receive an SRE Checkpoint periodically. Each SRE Checkpoint will take 1 day, and each AppSRE engineer will conduct one per sprint. [Further information](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/process/sre_checkpoints.md).
