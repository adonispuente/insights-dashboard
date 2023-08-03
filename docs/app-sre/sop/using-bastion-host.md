# Bastion access for tenants

`bastion.ci.int.devshift.net` host is used to access private clusters, clusters with API servers that are not exposed to internet. The bastion is located in a VPC peered with the private clusters managed in app-interface.

We give bastion access for tenants that work with our private clusters, such as hive/hypershift:

* If a person has a user file in app-interface, and that user file grants them access to a private cluster, the infra request is as good as approved, there's no need for further manager approval.
* If the user in app-interface does not have access to the private clusters, it means that they didn't ask for the roles in app-interface yet.

Once the infra MR is merged, there is no need to do anything manual. This [job](https://ci.int.devshift.net/job/node-user-housekeeping/) will take care of deploying the public key in the bastion.

## Getting access to bastion host bastion.ci.int.devshift.net
1. Make MR with your public part of SSH key to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/bastion.ci.int.devshift.net)
1. Your MR should be merged in shortly as it will appear in the IC's review queue which they check frequently
1. Check in several minutes after merge that You have access by `ssh bastion.ci.int.devshift.net`

## Get IP's for private clusters you are accessing
1. Go to [visual app-interface](https://visual-app-interface.devshift.net/clusters)
1. Select the cluster you want to access
1. Find `<network.vpc>` CIDR (network address)

## Use 'sshuttle' for tunelling to private cluster from your PC
1. Make sure you have package 'sshuttle' installed.
1. If you are using mac run: 
` sudo route add -net <network.vpc> -interface en0`
1. `sshuttle -r bastion.ci.int.devshift.net <network.vpc>`
* Note: You can specify several ranges like: `sshuttle -r bastion.ci.int.devshift.net <network.vpc>  <network.vpc> ...  <network.vpc>`


### Access PrivateLink cluster

1. `sshuttle -r bastion.ci.int.devshift.net <network.vpc> --dns`

1. If you are using mac, `--dns` option does not work. Instead, following local /etc/hosts config are needed for accessing PrivateLink cluster.
```
10.170.31.37 api.backplanes03ue1.be2s.p1.openshiftapps.com
# *.apps.backplanes03ue1.be2s.p1.openshiftapps.com
10.170.30.158 console-openshift-console.apps.backplanes03ue1.be2s.p1.openshiftapps.com
10.170.30.158 oauth-openshift.apps.backplanes03ue1.be2s.p1.openshiftapps.com
10.170.30.158 prometheus.backplanes03ue1.devshift.net
10.170.30.158 alertmanager.backplanes03ue1.devshift.net
```
