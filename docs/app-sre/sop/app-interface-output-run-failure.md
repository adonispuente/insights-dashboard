# App-interface output job failure

The app-interface output job is running the [run.sh](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/run.sh) script.

This script runs [qontract-cli commands](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/e9d5a55899cf90b8fc47e8f9a51349346ec5af58/run.sh#L12) listed in data/services/app-interface/cicd/ci-int/jobs.yaml

If the job is failing, look at the logs to understand which qontract-cli command failed, and debug accordingly.

In most cases, if this job failed, it is related to the last Pull Request that was merged to qontract-reconcile.

> Note: the job uses the latest image: https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/e9d5a55899cf90b8fc47e8f9a51349346ec5af58/run.sh#L14

If the failure does not seem to be related to the last changes, try to run the job again.

If the failure persists and the error is still not found, create a bug in Jira and raise awareness with the team.
