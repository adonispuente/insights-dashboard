# SOP : Jenkins

[TOC]

---

# Alerts

## JenkinsHealthCheck

This checks the health score `jenkins_health_check_score` of the jenkins instance, which include the state of the nodes/slaves.

A score below 1 do not necessarily mean there is an impact on the normal operations.

### Impact:

Variable

### Summary:

https://wiki.jenkins.io/display/JENKINS/Metrics+Plugin

### Access required:

Admin access to jenkins is required to troubleshoot this alert

### Steps:

Things to check:
- https://ci.int.devshift.net/metrics/currentUser/healthcheck?pretty=true or https://ci.ext.devshift.net/metrics/currentUser/healthcheck?pretty=true
- Nodes status:
  - Manage Jenkins -> Manage Nodes

- Nodes available disk space
  - Verify /tmp (/) 
  - Verify /var/lib/jenkins
  - Verify /var/lib/docker. Clean with `docker system prune -a`.
  - Duplicity backups cache can fill up in /root/.cache/duplicity
    - Clear old backups with: /backup/backup.sh remove-older-than 3M

---

## JenkinsNodeOffline

### Impact:

Degraded or even unavailable CI service. PR and MR checks fail,
tenants can't build new images of their applications.

### Summary:

A Jenkins executor is not responding to SSH and thus can't receive
jobs. The integration service is degraded.

### Access required:

See [the general openstack SOP](openstack-ci-int.md).

### Steps:

Reboot or restart all the affected nodes. Identify their names from
the alert, and then use `openstack server reboot --hard $server_name`.

If they don't come back, escalate to PSI. Cut a [Service Now
ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=4c66fd3a1bfbc4d0ebbe43f8bc4bcb6a)
-- yes, really. Mark impact as 3, and urgency as 3 or 2.

---

## JenkinsExecutorSaturation

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---

## JenkinsJvmMemoryStarvation

### Impact:

Unreliable CI service. PR and MR checks fail,
tenants can't build new images of their applications.

### Summary:

Jenkins controller using too much of RAM, after OOM event service might be unreliable
We need to restart the service at least

### Access required:

Admin access to Jenkins controller's Web-UI

### Steps:

- Check if it's really a problem - visit https://ci.int.devshift.net/monitoring?part=heaphisto
Pay attention if bottom line before table shows near to limit usage of RAM

- Check if 'hudson.plugin.git.*' object is present and bigger than a few MegaBytes. 
- Image for reference showing the problem ![before running script](images/ci-int-memory-histogram-before-script-screenshot.png)
- If it's big then need to execute [script](https://plugins.jenkins.io/git/#plugin-content-remove-git-plugin-buildsbybranch-builddata-script)
- Image for reference showing the remediation ![before running script](images/ci-int-memory-histogram-after-script-screenshot.png)

Note: running script also trims down disk usage by removing git revisions' builddata from all builds stored on controller and its backups

---

## JenkinsJvmCPUStarvation

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---

# Restarting Jenkins

There are several methods of restarting Jenkins, depending on severity of problems with service:

## Safe restart

Use systemd as you would with any other service:

``` shell
systemctl restart --no-block jenkins
```

This will let all ongoing jobs finish before restarting the
daemon. Jenkins jobs can take up to 15 minutes. If the restart doesn't
complete within 20 minutes, systemd will kill Jenkins and any leftover
jobs (which were stuck in some Java loop anyways).

**NOTE:** If you forget `--no-block` your terminal will be stuck for a
long time! You can press control+C to get back to the prompt.

## On a hurry

You can kill Jenkins directly:

``` shell
systemctl kill jenkins -s TERM
```

Please note, doing this will lose track of any ongoing jobs.

## Rebooting the controller

* `systemctl reboot` will reboot the controller after letting all jobs
  finish.
* `systemctl reboot -f` will reboot the controller killing all ongoing
  jobs.
* `systemctl reboot -f -f` will perform an unclean shutdown. It is the
  equivalent of yanking the power cord and connecting it again.
---
