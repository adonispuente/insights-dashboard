# Interrupt Catching Process

The interrupt catcher is a rotation that dedicates an AppSRE engineer to triage or process incoming incidents, alerts, and tenant requests. The goal is to have a defined escalation point to reduce the number of interruptions to the rest of the AppSRE team.

The IC schedule matches the AppSRE escalation policy in Pager Duty, which is [Follow The Sun](https://redhat.pagerduty.com/schedules#PQ022DV) when someone is defined, and [Primary Oncall](https://redhat.pagerduty.com/schedules#PHS3079) otherwise.

[TOC]

## AppSRE engineer guide to IC responsibilities

There are several tasks that are expected of the AppSRE engineering acting as the IC for the shift. They are listed below in the order of priority.

#### 1. Respond to critical alerts that are sent via Pagerduty (also sent to [#sd-app-sre-oncall](https://redhat-internal.slack.com/archives/CKN746TDW))

`critical` or `critical-fts` alerts are an indicator that a service is significantly degraded or completely down, the latter being for alerts that only page us when there is FTS coverage. These incidents are the highest priority for the IC engineer, regardless of any other responsibilities such as meetings or other tasks on this list. The IC engineer should respond to these incidents as soon as possible and escalate to others on the team if you are unable to do so for any reason.

Ensure that you are familiar with the [incident response doc](/docs/app-sre/incident-process.md) and use the criteria in that document to determine whether to declare an incident. When in doubt do not hesitate to escalate incidents to others within the AppSRE team.

#### 2. Respond to user-reported issues affecting production in [#sd-app-sre](https://redhat-internal.slack.com/messages/CCRND57FW/)

There are several types of issues that fall within this category including:

* A user reports a production issue that hasn't triggered an alert (we try to avoid this, but it can happen)
* A user needs an MR merged because they're actively investigating a production issue (this is the only time a tenant should be directly pinging the IC to merge an MR)

It is important to evaluate the actual impact to the service when these reports come in. Sometimes these could be false positives (client-side issues), but other times they are not. For these situations, if there aren't any active alerts, you'll want to escalate to the tenant team for assistance with assessing impact, and see the criteria in the [incident response doc](/docs/app-sre/incident-process.md) to determine if an incident needs to be declared.

#### 3. Review app-interface merge requests

The majority of changes to resources managed by app-interface need to be approved by an AppSRE engineer. The IC engineer is responsible for handling these reviews during their shift. There is a separate guide for more details on [reviewing app-interface MRs](/docs/app-sre/sop/app-interface-review-process.md).

Useful dashboards:
[Merge queue](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/app-interface-merge-queue.md)
[Review queue](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/app-interface-review-queue.md)

Be aware, that some requested changes might actually require a new onboarding process.
We have a [checklist](/docs/app-sre/re-onboarding-checklist.md) to help drive the decision.

#### 4a. Review ASIC tickets

The IC engineer should review any open [ASIC](https://issues.redhat.com/projects/ASIC/issues/) tickets and attempt to resolve them, or at least start the investigation and post and findings to the ticket.

A few basic rules about ASIC tickets:

* ASIC tickets are a collaborative effort. They exist because keeping context in a ticket is much easier in JIRA. Please always add enough context and information so that it can be picked up by the following IC.
* ASIC tickets must not be owned by any engineer. If by any chance you feel that you should own a ticket so that it is properly addressed, then it doesn't belong to ASIC project any longer: move it to `APPSRE` board and assign it to yourself. If not, just add all the information that you have gathered and unassign it once your shift is done.
* Do not let ASIC tickets rot: if a solution has been provided to the tenant that created it, just close it giving the tenant the possibility to reopen if needed.

#### 4b. Answer users questions in [#sd-app-sre](https://redhat-internal.slack.com/messages/CCRND57FW/) that aren't impacting production

Users will often ask questions in [#sd-app-sre](https://redhat-internal.slack.com/messages/CCRND57FW/) such as how to perform some task in app-interface, or other general questions. Keep the following in mind when answering questions in this channel:

1. If the application is `InProgress`, then the question should be asked in [#sd-app-sre-onboarding](https://redhat-internal.slack.com/archives/C02CMTM9GG1).
2. Sometimes users will ask about an issue with their OSD cluster. We only assist in cases where the cluster is managed by app-interface, otherwise they've probably mistaken us for [#sd-sre-platform](https://redhat-internal.slack.com/archives/CCX9DB894)

#### 5. Respond to high alerts in [#sd-app-sre-alert](https://redhat-internal.slack.com/archives/CDW0S85QU)

`high` alerts are sent to the [#sd-app-sre-alert](https://redhat-internal.slack.com/archives/CDW0S85QU) Slack channel. The IC engineer doesn't need to respond to these immediately, but we should attempt to keep an eye on alerts that are recurring. The general process for dealing with these alerts is:

1. Click on the **Runbook** link in the channel alert channel to access the SOP
2. Read through the SOP and attempt to resolve the issue
3. Escalate to the tenant team if you cannot resolve the issue with the SOP
4. When the issue is mitigated/resolved, search through the alerts Slack channel to see if this alert has been trending, or if there were concerns because the SOP was incomplete, create an [ASIC](https://issues.redhat.com/projects/ASIC/issues/) ticket to track working with the team to fix the alert or underlying issue

**IMPORTANT**: The maintenance of the `#sd-app-sre-alert` channel is to be done by the IC. If the channel is overloaded with flappy alerts, then it is of no use to anyone, and important things can be missed. It is the duty of the IC to make sure alerts in that channel are actionable and not flappy. If you detect a flappy alert, downgrade its severity to `medium` and let the tenant know so that they can work on restoring the trust of the alert so that it can reach us again.

### Additional notes

* Keep in mind that the priorities of the tasks above are a general guide, but we want to keep in mind the [SLOs that we've defined for the team](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md#service-agreements).
* If you are having a very busy shift (an incident / many alerts), don't hesitate to ask for assistance in [#sd-app-sre-teamchat](https://redhat-internal.slack.com/archives/GGC2A0MS8) if you're falling behind on tasks that are near breaching their SLO. It's possible that someone else can jump in quickly to assist with taking a look at alerts, MRs, etc.
  * TODO: it'd be good if we were more actively tracking SLOs on the different tasks listed above so that it's clearer when the IC is falling behind

### Handover process

There is a Slack reminder (see `/remind list`) setup in the [#sd-app-sre-handover](https://redhat-internal.slack.com/archives/C019FBYNL4F) channel to remind the IC to perform a handover.

The handover should include:

1. A status update of any active issues that you're working on that need attention from the oncoming IC
2. Any helpful information such as "I didn't have much time to review app-interface MRs, so there are many in the queue"

Please be sure to complete a handover even if it is "There are no issues to handover."

## Resources

### Incident response

The [incident response doc](/docs/app-sre/incident-process.md) covers this topic at length. Ensure that you're familiar with this document for your IC and on-call shifts.

### Access to systems

- [AAA - Anthology of App-SRE Axioms](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md) - ensure that you have access to all required systems

### Tenant questions

- [Developer guidelines](https://gitlab.cee.redhat.com/service/dev-guidelines)
- [App-Interface Frequently Asked Questions](https://gitlab.cee.redhat.com/service/app-interface/blob/master/FAQ.md)
- [Service Delivery support](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/support.md) - for OpenShift upstream issues

## AppSRE engineer guide to onboarding-ic responsibilities

Apart from the mentioned regular IC shift, we have a separate rotation called onboarding-ic that follows a weekly [schedule](https://gitlab.cee.redhat.com/service/app-interface/-/blob/09594ca5b63a260c3ac010600f9f0f5e7349b1dd/data/teams/app-sre/schedules/app-sre-onboarding-ic.yml). This rotation doesn't comply to the [SLO](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md#service-agreements) mentioned above.

onboarding-ic's tasks during shift are:
1. Watching [#sd-app-sre-onboarding](https://redhat-internal.slack.com/archives/C02CMTM9GG1) channel and answers tenant's questions.
2. Review all open MRs with the label `onboarding` or an `InProgress` service status. 
  \* Specifically for SLO MRs, onboarding-ic should also do as much as possible to let the assignee of the onboarding epic know this change had happened and preferably defer it to the assignee to merge the MR. We recommend that 1. assign the MR to the assignee of the onboarding epic ticket( [onboarding Jira board](https://issues.redhat.com/secure/Dashboard.jspa?selectPageId=12341197) is where you can find them) 2. Find the SLO Review ticket under the epic, then comment it in the MR if it wasn't mentioned already. 
  This will greatly reduce turnaround time during SLO MR review and make the onboarding process smoother.
