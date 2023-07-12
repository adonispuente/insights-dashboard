# Jenkins Vault Policies
Jenkins uses a Vault AppRole to access secrets in jobs. This is tied with a Vault policy granting read
access to specific mounts for their use in jobs.

See [README](/README.md#manage-jenkins-jobs-configurations-using-jenkins-jobs) for more information about how
a Jenkins job is constructed within App Interface.

If you need to update a policy to provide Jenkins access to read additional secrets from new mounts, you will
need to make updates to the following files depending on which instance is running the job.

## ci-int
[app-sre-ci-approle-policy](/data/services/vault.devshift.net/config/prod/policies/app-sre-ci-approle-policy.yml)

[associated approle that uses this policy](/data/services/vault.devshift.net/config/prod/roles/approles/hsd_ci_approle-approle.yml)

## ci-ext
[app-sre-ci-ext-approle-policy](/data/services/vault.devshift.net/config/ci-ext/policies/ci-ext-approle-policy.yml)

[associated approle that uses this policy](/data/services/vault.devshift.net/config/ci-ext/roles/approles/ci-ext-jenkins.yml)
