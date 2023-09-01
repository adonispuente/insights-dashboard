ProvisioningMissingPodAlert
===========================

Impact
------

Provisioning will not be able to work correctly.

Summary
-------

This alert fires when provisioning pods are not available or is seems so from Prometheus metrics.

Access required
---------------
- The stage cluster to view the [provisioning-stage namespace][provisioning-stage-namespace].
- The production cluster to view the [provisioning-prod namespace][provisioning-prod-namespace].
- The provisioning [grafana stage dashboard][grafana-stage].
- The provisioning [grafana prod dashboard][grafana-prod].

Steps
-----
- View the namespace for [stage][provisioning-stage-namespace]/[prod][provisioning-prod-namespace] to verify provisioning pods are running.
- See if there are any Pods crash looping, see the logs for obvious errors, describe pods to find potential errors, get namespace events...
- See the Clowder deployment status [stage][provisioning-stage-clowder]/[prod][provisioning-prod-clowder] for any obvious errors
- Try restarting the pods

Escalations
-----------

[Escalation policy](data/teams/insights/escalation-policies/crc-provisioning-escalations.yml).



[provisioning-stage-namespace]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/provisioning-stage/services
[provisioning-prod-namespace]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/project-details/ns/provisioning-prod
[provisioning-stage-clowder]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/provisioning-stage/cloud.redhat.com~v1alpha1~ClowdApp/provisioning-backend
[provisioning-prod-clowder]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/provisioning-prod/cloud.redhat.com~v1alpha1~ClowdApp/provisioning-backend
[grafana-stage]: https://grafana.stage.devshift.net/d/211/provisioning?orgId=1
[grafana-prod]: https://grafana.app-sre.devshift.net/d/211/provisioning?orgId=1
