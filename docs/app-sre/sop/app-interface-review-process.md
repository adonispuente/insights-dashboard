# App Interface review process

This is a WIP SOP intended for use by App SRE team members acting as Interrupt Catcher or just reviewing merge requests to app-interface.

## Process

1. Verify that build passes.
2. Verify that the `app-interface JSON validation` report is as expected due to the changes introduced in the MR.
3. Check specific review instructions (see [specific-review-instructions](#specific-review-instructions))
4. If any additional reviewers are required, ping them on the MR (see [additional-reviewers](#additional-reviewers)).
5. Once the MR looks good to you, add the `lgtm` label or comment `/label lgtm`. The MR will be merged automatically within minutes. See also the documented [approval process](/docs/app-sre/continuous-delivery-in-app-interface.md#approval-process)

## Notes

* Some merge requests will be created with an `automerge` label. No need to review or merge those.

## Specific review instructions

### saas-deploy image_pattern

This change indicates that an additional component will be allowed to be deployed to a production namespace.

Action items:
* verify the existence of a matching SOP for the additional component before merging

### Insights

Insights MRs should be approved as follows:

- Onboarded services - AppSRE
- Not onboarded - @bturner
- FedRAMP - @klape

**Note:** the reviewers above are able to add lgtm labels in GitLab

## Additional Reviewers

### Telemeter access

Access to Telemeter is approved by the telemetry-sme list: telemetry-sme <telemetry-sme@redhat.com> 

The best way to request access is to email that list, point at the MR and ask for approval.

### Insights cluster access

The following folks can be asked to review MR when in doubt:

```
- @klape
- @bturner
- @mafriedm
```

### Managed services access

Access to Managed Services should be approved by one of the following:

```
- @weil
- @stobin
- @dbizzarr
```
