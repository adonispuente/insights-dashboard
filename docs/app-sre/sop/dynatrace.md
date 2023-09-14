# Dynatrace

## Restart Log Configuration Job

We have 2 ways of restarting the job.

### Restart Job for a single cluster

1. Create and merge an MR that deletes (comments out) the job resource from the dynatrace namespace.

**/data/openshift/<cluster>/namespaces/dynatrace.yml**
```
openshiftResources:

...

#- provider: resource-template
#  type: jinja2
#  path: /setup/dynatrace/log-config-job.yaml.j2
#  enable_query_support: true
```

2. Create and merge an MR that uncomments the above to add the job again.

### Restart Jobs on all clusters having dynatrace installed

Re-start all log-configuration jobs in all clusters by changing the [job name](https://gitlab.cee.redhat.com/service/app-interface/-/blob/d682a17bf8612a2cc8eee0f5354981b6841e4a6b/resources/setup/dynatrace/log-config-job.yaml.j2#L14) (increment version number).
Note, that the jobs are idempotent, i.e., it is totally fine and safe to re-run them.
However, restarting on all clusters might raise alerts if the re-runs fail.

## Install Dynatrace On Cluster

1. Create a new cluster token in dynatrace-config, see [MR](https://gitlab.cee.redhat.com/service/dynatrace-config/-/merge_requests/186)
2. Define DT environment for cluster and install token, see [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79135)
3. Install DT Operator via saas file, see [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79141)
4. Install DT Resources -> important: make sure you also enable at least one namespace, see [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79143)
