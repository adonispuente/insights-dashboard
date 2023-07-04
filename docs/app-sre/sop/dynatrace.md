# Dynatrace

## Restart Log Configuration Job

Re-start all log-configuration jobs in all clusters by changing the [job name](https://gitlab.cee.redhat.com/service/app-interface/-/blob/d682a17bf8612a2cc8eee0f5354981b6841e4a6b/resources/setup/dynatrace/log-config-job.yaml.j2#L14) (increment version number).
Note, that the jobs are idempotent, i.e., it is totally fine and safe to re-run them.
However, restarting on all clusters might raise alerts if the re-runs fail.
