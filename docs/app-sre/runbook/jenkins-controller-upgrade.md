# Upgrading of Jenkins Controller Service

[TOC]

## Introduction

See [the OS upgrade workflow](./jenkins-os-upgrade-workflow.md) for information on
rpm/yum updating other packages installed on the system.

Jenkins controller software is divided into 2 parts - core service (the Jenkins application) and plugins

1. For updating core system we're using yum command, like `yum update jenkins`
2. For updating plugins, you will need to use the web interface.
    1. [ci-int](https://ci.int.devshift.net/manage/pluginManager/)
    2. [ci-ext](https://ci.ext.devshift.net/manage/pluginManager/)
    3. [ci-stage](https://stage.int.devshift.net/manage/pluginManager)


## When to update

After critical security fixes made public we usually have 90 day windows for upgrading Jenkins controllers

It initiated by ProdSec posts to lists:
1. product-security-cicd-tool-data
1. prodsec-supplychain


## What is updated

All 3 environments need to be updated:

1. [Stage](https://stage.int.devshift.net/)
1. [CI-ext](https://ci.ext.devshift.net/)
1. [CI-int](https://ci.int.devshift.net/)


## Preparations
1. Prepare a merge request in the App Interface repo that bumps a QR hash to use for validation.
Ensure that a build runs prior to upgrading so that you have results to validate
after the upgrade.
1. Run through the [LTS Guide](https://www.jenkins.io/doc/upgrade-guide/) to ensure
that no breaking changes will affect AppSRE.
1. Make sure you have [ssh access](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all#L5) to controllers' hosts
1. Announce some downtime in Slack channel #sd-app-sre
1. Make sure you have backups of configs (/var/lib/jenkins/backup)
    1. Take a Thin Backup of Jenkins settings (https://ci.int.devshift.net/thinBackup)
    1. Copy the `/var/lib/jenkins/backup` directory to an S3 bucket
    1. Create an [EC2 backup](https://docs.aws.amazon.com/prescriptive-guidance/latest/backup-recovery/ec2-backup.html) of the controller node.
    This is done because Jenkins does not support downgrades.
    An example of the CLI command for an EC2 backup: `aws backup --profile <your_profile> start-backup-job --region us-east-1 --backup-vault-name Default --resource-arn <ec2_arn> --iam-role-arn arn:aws:iam::<aws_account>:role/service-role/AWSBackupDefaultServiceRole --lifecycle DeleteAfterDays=30`
1. If you updating plugins it's good idea to copy current plugins binaries (`/var/lib/jenkins/plugins`) to some safer location like AWS S3. You can download older versions of plugins but having them stored locally will speed-up process if you need to restore


## Plugin updates
Note that some plugin upgrades require a restart of Jenkins.

Plugins can be updated through [the UI](https://stage.int.devshift.net/pluginManager).
You can generate a list of plugins to upgrade and version numbers with
the following Groovy script which can be entered into the Jenkins console:

(This is useful for compliance reasons)

```groovy
def pluginList = new ArrayList(Jenkins.instance.pluginManager.plugins)

pluginList.sort { it.getShortName() }.each{
  plugin ->
    if (plugin.hasUpdate()) {
      println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()} -> ${plugin.getUpdateInfo().version}\n${plugin.getUrl()}\n")
    }
}
```

## Upgrade

1. Make CI instance offline
    1. go https://stage.int.devshift.net/prepareShutdown/ which will stop
    new jobs from starting
    1. Type reason like "Update maintenance" and hit the button
1. Wait for all current jobs finished or abort some long-running ones
1. ssh to host `ssh stage.int.devshift.net` or whichever instance you are upgrading
1. Stop Jenkins controller service `systemctl stop jenkins`
1. `yun update jenkins` - please pay attention to exact version is picked for upgrade, sometime you need to specify exact version
1. Visit [Plugin-manager web-interface|](https://stage.int.devshift.net/pluginManager/) if you need to update/install plugins
1. Start Jenkins controller service `systemctl start jenkins`

## Validation
Utilize the earlier prepared test MR to test a build and ensure functionality is
retained without a difference in results. If successful then let folks know the maintenance is completed
and ensure that the Jenkins controller is no longer in a shutdown mode.

## Rollback
### Application Level
Firstly, in the event that configuration of Jenkins is somehow not transferred between versions,
you can restore the Thin Backup (Application level backup).
Do this by copying the contents of the backup from the S3 bucket back to `/var/lib/jenkins/backup`.
Then navigate to https://stage.int.devshift.net/thinBackup/.
If the plugin somehow hasn't been transferred between versions, then you will have to install the
plugin from Jenkins itself.

Now click the **Restore** button to restore the latest configuration.

### EC2 Level
In the event of a catastrophic failure causing Jenkins not to function at all, then you can restore
the EC2 backup. This is a bit trickier to describe using the CLI
so please follow the [AWS Guide on Restoring from EC2 Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-ec2.html).
Ensure other team members are following along through this process.
