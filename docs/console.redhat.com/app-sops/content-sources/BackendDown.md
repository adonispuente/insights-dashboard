ContentSourcesAvailabilityAlert
==========================

Impact
------

The api server is down.  No users requests can be fufilled.

Summary
-------

This alert fires when a backend Api pods are no longer running

Access required
---------------
- The stage cluster to view the [content-sources-prod-namespace]( https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/project-details/ns/content-sources-prod).
- The production cluster to view the[content-sources-stage-namespace](https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/content-sources-stage/services).
- The stage Kibana instance to view the [content sources stage logs][content-sources-kibana-stage](https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana#/discover?).
- The production [Kibana instance](https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover)
- The content-sources [Stage grafana](https://grafana.app-sre.devshift.net/d/content-sources/content-sources?orgId=1&var-datasource=crcp01ue1-prometheus&from=now-7d&to=now)
- The content sources [Prod grafana](https://grafana.app-sre.devshift.net/d/content-sources/content-sources)


Steps
-----
- View the namespace, check pod console output to see if there are any messages when the pods are starting
- View the dashboard to see the trend of errors.
- View the logs to identify specific errors.

Escalations
-----------

[Escalation policy](data/teams/insights/escalation-policies/crc-content-sources-escalations.yml).
