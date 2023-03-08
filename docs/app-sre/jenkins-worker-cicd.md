# Continuous Integration and Delivery For Jenkins Worker Nodes

## Overview

Continuous Integration means building AMIs for the Jenkins worker nodes.

Continuous Delivery means deploying instances via AWS Auto Scaling groups (ASGs).

## Continuous Integration

We use the Ansible Packer provisioner to build different AMIs based on different base AMIs (we are using CentOS 7, RHEL 7, and RHEL 8) and run different roles. Packer configuration can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/packer). Each new commit [that makes changes](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/build_images.sh#L51-56) under that folder will trigger a building process for all types of worker nodes. The roles configuration for each kind of node can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/packer/ansible/jenkins-worker.yaml). To add a new type would also require adding a new source in packer [config](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/packer/worker.pkr.hcl#L40-80).

For security, all AMIs are built in [app-sre-ci](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-ci/account.yml) account in a dedicated VPC. Once the AMIs get built successfully, they will be shared into `app-sre` account via [aws-ami-share](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/aws_ami_share.py). Sharing configuration can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-ci/account.yml#L47-50)

AMIs are built every time a file inside the `packer` directory of [`infra`](https://gitlab.cee.redhat.com/app-sre/infra) repository is modified. See [`build_images.sh`](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/build_images.sh) for details:

### Tests

In a MR, AMIs are also tested using [`ami-tests`](https://gitlab.cee.redhat.com/app-sre/ami-tests), a test runner for [testinfra](https://testinfra.readthedocs.io/en/latest/) tests.

### OS Upgrades

Every time an AMI is built, all the packages are upgraded in the [`baseline`](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/packer/ansible/roles/baseline/tasks/main.yml#L1) role. If we want to upgrade AMIs, we just have to introduce a trivial change under the `packer` directory. The file `packer/FORCE_AMI_BUILD` exists for that purpose. In order to force a new ami build just:

```
date -u > packer/FORCE_AMI_BUILD
```

and create a MR in the `infra` repo.

## Continuous Delivery

We use [terraform-resources](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#manage-aws-autoscaling-group-via-app-interface-openshiftnamespace-1yml) to create and manage auto-scaling groups. One example can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/namespaces/app-sre-ci.yaml#L96-116).

`images` helps us to trace the latest amis and trigger Instance refresh when new amis get to build.

`extra_tags` helps us to trace these dynamic instances for monitoring and running housekeeping jobs.

Once an AMI has been correctly built and shared with the AWS account where the ASG is defined, in order to make it use the `ref` has to be updated. Due to the scale-in protection the plugin does it make take a while for the changes to take place. If absolutely needed, the instances can be manually terminated until [this work](/docs/app-sre/design-docs/jenkins-worker-fleet.md) is completed.

## Jenkins Plugin

Jenkins master node require IAM role to be able to manage its own node. Policy can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/app-sre-ci/ci-int-nodes.tf#L131-187)

Once the ASG has been created, we can define Jenkins worker fleets in app-interface and auto-update it in Jenkins instances via JCasC(Jenkins Configuration as Code) with the help of [jenkins-worker-fleet](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/jenkins_worker_fleets.py). One example can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ci-int/ci-int.yml#L20-28). 

## Monitoring

For the auto-scaling group, we enable [CloudWatch metrics](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/app-sre/production/ci-int-asg-1.yml#L18-39). So we can get them via AWS console [for example](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AutoScalingGroupDetails:id=ci-int-jenkins-worker-app-interface;view=monitoring)

For running nodes, since all nodes are running node-exporter, we use [ec2_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config) to retrieve scrape targets from AWS EC2 instances. Configuration can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig-internal.secret.yaml#L176-190). and all targets can be found [here](https://prometheus.appsrep05ue1.devshift.net/targets#pool-jenkins_worker)

### Dashboards

We have two dashboards related to Jenkins workers:

* Jenkins nodes: https://grafana.app-sre.devshift.net/d/IfKto8hVz/jenkins-nodes?orgId=1
* Node exporter full: https://grafana.app-sre.devshift.net/d/rYdddlPWk/node-exporter-full?orgId=1

The first one can be used to find issues in certain nodes filtering by node types. If there's a problem with a certain node, you can then get extended information by using the Node exporter full dashboard

### Jenkins UI metrics

There's a Jenkins UI metrics that can be used to gain additional insights, especially around JVM issues:

* Jenkins master: https://ci.int.devshift.net/monitoring
* Jenkins workers: https://ci.int.devshift.net/monitoring/nodes

## Housekeeping

We still need to running some housekeeping jobs to help us manage these nodes. We use ansible [ec2 inventory](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html) to get inventory hosts and run jobs against it. Host configuration can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/aws_ec2.yaml). Job definition can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/jenkins/app-sre/job-templates.yaml#L203-250) and jobs are [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/jobs.yaml#L104-118)

## Log in to Jenkins workers

Log in to a dynamically created Jenkins node is the last option to debug a problem. Consider first using the above dashboards or spinning a new node using the same AMI to debug issues. If that is not enough, you may be able to ssh into the instance to do further debugging.

IMPORTANT: **Never do any manual change in a dynamic node**. Changes must be done in the [Packer](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/packer) configuration.

Dynamic nodes are part of ASGs, hence the way to know which is the IP associated is by querying into the AWS account of the ASG (usually `app-sre`) since this information is not shown by Jenkins. Using AWS cli:

```
aws ec2 describe-instances --instance-ids <instance-id> | jq -r .Reservations[].Instances[].PrivateIpAddress
```

where `<instance-id>` is shown in Jenkins UI, e.g. `i-08c2168b1bb67b8eb`

Once you have the IP, you can use your own RedHat user to log in.

As a quick workaround, you can use the [dynamic inventory](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/aws_ec2_host.json) used by the Housekeeping jobs to find the IP of a host.
