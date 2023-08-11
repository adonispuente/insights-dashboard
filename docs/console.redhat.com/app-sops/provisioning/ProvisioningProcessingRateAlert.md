ProvisioningProcessingRateAlert
===============================

Impact
------

Provisioning instance launch reservation is not getting processed and reservation queue is filling up.

Summary
-------

This alert fires when the workers pods are unable to complete reservations and jobs (reservations) are kept in pending state for longer than 10 minutes. If more than 20% of all reservations in the time window of last 24 hours, the alert is triggered.

Access required
---------------
- The stage cluster to view the [provisioning-stage namespace][provisioning-stage-namespace].
- The production cluster to view the [provisioning-prod namespace][provisioning-prod-namespace].
- The stage Kibana instance to view the [provisioning stage logs][provisioning-kibana-stage].
- The production Kibana instance to view the [provisioning production logs][provisioning-kibana-prod].
- The provisioning [grafana stage dashboard][grafana-stage].
- The provisioning [grafana prod dashboard][grafana-prod].

[provisioning-stage-namespace]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/provisioning-stage/services
[provisioning-prod-namespace]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/project-details/ns/provisioning-prod
[provisioning-kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:provisioning'),sort:!())
[provisioning-kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:provisioning'),sort:!())
[grafana-stage]: https://grafana.stage.devshift.net/d/211/provisioning?orgId=1
[grafana-prod]: https://grafana.app-sre.devshift.net/d/211/provisioning?orgId=1

Steps
-----
- Check if one of the supported cloud providers does not have outage
- Verify that at least 3 pods of `provisioning-worker` are running
- Check Kibana for reservations, use `@log_group: "provisioning-cloudwatch-stage" and @log_stream: "worker"` to access worker access logs
- Use `reservation_id: 14697` to check for a particular reservation id
- Restart worker pods or the whole application


Escalations
-----------

[Escalation policy](data/teams/insights/escalation-policies/crc-provisioning-escalations.yml).
