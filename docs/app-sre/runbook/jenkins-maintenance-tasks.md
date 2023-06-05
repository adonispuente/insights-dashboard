# Jenkins maintenance tasks

[TOC]

## Overview

This SOP captures MANUAL steps for maintenance tasks of AppSRE CI infrastructure.

Examples for ci-int, but same steps can be used for ci-ext by changing hosts.

## Architecture

![AppSRE Jenkins](img/jenkins.png "App SRE Jenkins Architecture")

## Needed credentials:

1. [Admin credentials](https://gitlab.cee.redhat.com/service/app-interface/-/blob/5a22e57f229648403c4e7882233f559066a9f0bb/data/teams/app-sre/roles/app-sre.yml#L14-15) for accessing jenkins UI
1. ssh access to controller: [direct](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all#L5) or [app-sre-bot](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ansible/roles/app-sre-bot) key for running ansible commands

## Weekly maintenance tasks

1. Make CI instance offline
  - go https://ci.int.devshift.net/prepareShutdown/
  - Type reason like "Weekly maintenance" and hit the button
  - announce in #sd-app-sre Slack channel
1. Wait for all current jobs finished or abort some long-running ones
1. Stop jenkins controller service
  - ssh to host `ssh ci.int.devshift.net`
  - `# systemctl stop jenkins`
  - NOTE: you need to stop service before rebooting controller VM. This is critical step. In case of rebooting without *prior* stopping of jenkins service reboot command may kill _ssh_ daemon and wait jenkins controller for graceful stop upto 35 minutes. That may lock instance for that period of time.
1. Update kernel on controller: `# yum -y update kernel`
1. Clean /tmp folder on workers nodes: `# rm -rf /tmp/*`
1. Schedule reboot of controller: `# shutdown -r 1`
1. Announce end of maintenance in #sd-app-sre Slack channel

## Final check:
Go to controller console and check all workers node for status and free disk space, sometime you may need to clean some, usually by removing old container images

## Further reading

See [this doc](/docs/app-sre/jenkins-worker-cicd.md) to have more information on how to handle Jenkins dynamic nodes.

## Additional steps for monthly maintenance

### Build new version of controller AMIs

**NOTE**: Do this before any other task, as it takes time.

* Go to [`infra`](https://gitlab.cee.redhat.com/app-sre/infra) and force a new ami build:
    ```
    date -u > packer/FORCE_AMI_BUILD
    ```
### Cleanup old builds

**NOTE**: It's better to run this script before stopping jenkins service

We need to cleanup old builds data by running groove script, as described in [Git plugin doc|https://plugins.jenkins.io/git/#plugin-content-remove-git-plugin-buildsbybranch-builddata-script]

1. Open [script console|https://ci.int.devshift.net/manage/script]
1. Paste content of script
1. Hit Run button

### Deploy new AMIs

**NOTE**: Do this at the end of the maintenance window.

1. Check that new AMIs have been built correctly in https://ci.int.devshift.net/view/app-sre/job/app-sre-infra-gl-build-master/
1. Take a note of the merging sha from the MR used to build the new AMIs. It it important to note that most likely it won't be the last one from the infra repository, as there are many pushes to that repository.
1. Update the sha reference of the AMIs in the [ASGs configuration](/data/services/app-sre/namespaces/app-sre-ci.yaml).
