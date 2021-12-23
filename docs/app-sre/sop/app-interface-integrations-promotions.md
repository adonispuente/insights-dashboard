# App-interface integrations promotions

## Background

App-interface integrations are being executed in multiple locations in multiple ways.  This SOP explains how to promote a new version of our integrations to each location.

## Process

1. If the app-interface changes you are promoting are dependent upon a schema change in [qontract-schemas](https://github.com/app-sre/qontract-schemas),
   the qontract-schemas version should be promoted first. This should be done by updating app-interface's `.env` file in its own merge request
   setting the commit sha reference from qontract-schemas repository. This can be done with `make update-schemas`
1. Create a MR in app-interface to promote your changes from staging to
   production. `make qr-promote` automates getting the latest commit
   checksum and updating the necessary files. Running `make qr-promote` will also update the `ref` field within our [saas-qontract-reconcile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml) file.  If there is a need to promote to
   a single environment, or for a better understanding of what `qr-promote` is
   doing, see [Updating specific environments](#updating-specific-environments).
1. Team members should deploy their own changes to production shortly after
   merging. In some cases, there might be changes queued up from multiple team
   members. **If your promotion will include changes from other team
   members, it is a courtesy to notify those team members.** Acknowledgements
   from team members will not block the promotion because merging a change
   indicates that it is production-ready.
1. Add a **lgtm** label to the MR via the GitLab website. The change will
   be merged as per the standard
   [continuous delivery process](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md).

## Updating specific environments

This section describes which files need to be updated in order to deploy to
a certain environment. This also serves as documentation for what
`make qr-promote` is automating for you.

* To promote integrations running in the app-sre-prod-01 cluster, update `ref` in [saas-qontract-reconcile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml).
* To promote integrations running in appsres03ue1 or in appsrep05ue1 (internal clusters), update `ref` in [saas-qontract-reconcile-internal](data/services/app-interface/cicd/ci-int/saas-qontract-reconcile-int.yaml).
* To promote integrations running in the app-interface pr-check job running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote openshift-saas-deploy version in all Jenkins jobs, update `qontract_reconcile_image_tag` in [global defaults](/resources/jenkins/global/defaults.yaml).
* To promote openshift-saas-deploy version in all Tekton pipelines, update `qontract_reconcile_image_tag` in [app-interface shared-resources](/data/services/app-interface/shared-resources).
    * Note: there may currently be additional shared-resources files containing `qontract_reconcile_image_tag`. It is usually needed to update all of them (search for `qontract_reconcile_image_tag`).
