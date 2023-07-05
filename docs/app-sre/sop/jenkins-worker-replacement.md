# Jenkins worker replacement

[TOC]

## Context

Sometimes a Jenkins worker starts misbehaving or gets stalled. Since workers are disposable and they get replaced often, we should not make any changes on them as those changes won't last.

Replacing a node is completely safe, it is taken care by the AutoScalingGroup (ASG) associated to the Jenkins worker type.

See [Jenkins worker CI/CD documentation](/docs/app-sre/jenkins-worker-cicd.md) for more details.

## Access

* Jenkins UI
* AWS app-sre account

## Procedure

* In the Jenkins UI, access the worker page (you may find it the work, in the main page or in Manage Jenkins > Manage Nodes and Clouds).
* Make sure that the node won't receive any further builds by pressing "Make this node temporarily offline".
* Wait for builds to finish (if deemed necessary).
* Terminate the instance in [AWS](https://950916221866.signin.aws.amazon.com/console). The instance id is in the Jenkins UI page. You can do this by login in the AWS Console or via the CLI:
   ```
   aws ec2 terminate-instances --instance-id <instance-id>
   ```
* You should see that a new worker of the same type appears soon.
