# Jenkins nodes access

[TOC]

## SSH access

app-sre members public keys in [infra](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all#L5) are distributed to all jenkins nodes (controllers and workers), so ssh is the normal way to log in.

### Controllers

* ci-int: ssh to `ci.int.devshift.net`
* ci-ext: ssh to `ci.ext.ssh.devshift.net`

### Workers List

Find a list of all available Jenkins nodes, including their IP addresses, in [the app-interface-output repo](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ec2-jenkins-workers.md)

### Workers

Log in to a dynamically created Jenkins node is the last option to debug a problem. Consider first using jenkins [dashboards](/docs/app-sre/jenkins-worker-cicd.md#dashboards) or spinning a new node using the same AMI to debug issues. If that is not enough, you may be able to ssh into the instance to do further debugging.

IMPORTANT: **Never do any manual change in a dynamic node**. Changes must be done in the [Packer](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/packer) configuration.

Dynamic nodes are part of ASGs, hence the way to know which is the IP associated is by querying into the AWS account of the ASG (usually `app-sre`) since this information is not shown by Jenkins. Using AWS cli:

```
aws ec2 describe-instances --instance-ids <instance-id> | jq -r .Reservations[].Instances[].PrivateIpAddress
```

where `<instance-id>` is shown in Jenkins UI, e.g. `i-08c2168b1bb67b8eb`

Once you have the IP, you can use your own RedHat user to log in.

**NOTE**: In order to log in ci.ext workers, you have to use `ci.ext.ssh.devshift.net` as jump host. The classic way is to use ssh's `ProxyCommand`:

```
ssh -o ProxyCommand="ssh -W %h:%p <RedHat user>@ci.ext.ssh.devshift.net" <jenkins-agent-ip>
```

If you have OpenSSH version >= 7.5, you can use the simpler `ProxyJump` via the `-J` switch:

```
ssh -J ci.ext.ssh.devshift.net <jenkins-agent-ip>
```

or add the following to your `~/.ssh/config` file:

```
# Jenkins dynamic instances on 192.168.16.0/20
Host 192.168.16.* 192.168.17.* 192.168.18.* 192.168.19.* 192.168.2?.* 192.168.30.* 192.168.31.*
  ProxyJump ci.ext.ssh.devshift.net
```

## Console access

In case ssh access is not available, nodes can still be accessed using EC2 serial console emulation from the AWS UI. In order to do that, press the "Connect" button in the instance page and then use `app-sre-bot` [password](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ansible/roles/app-sre-bot) to access. Once there, you can gain access to `root` account via `sudo su -`.

**NOTE:** User/password access is disabled in SSH configuration.
