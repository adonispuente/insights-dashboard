App-ingress-service-In-ingress-prod-high-downtime
=================================================

Severity: Pagerduty
-------------------

Impact
------

-  This alert fires when the app downtime exceeds 2% over 24 hours

Summary
-------

This alert tracks the downtime of the app over 24 hours. If it goes down that frequently. We should investigate.

Access required
---------------

-  Access to the production `Grafana`_ or instance in order to see the current error count
-  Access to the `Production Openshift cluster`_ to view the ingress-prod namespace for errors in upload-service
-  Access to the `Kibana instance`_ in order to review logs to see if there are any problems causing the failures

Steps
-----

-  Login to `Grafana`_ and view the `Ingress dashboard`_ to review the topics
-  Login to the ingress-prod project and see if there are any errors in the project or pods
-  If ingress is showing major issues, a redeploy may be necessary and can be safely done.

Escalations
-----------

-  Ping platform-infrastructure-dev or platform-data-dev Slack groups for assistance
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Grafana: https://grafana.app-sre.devshift.net/?orgId=1
.. _Production Openshift Cluster: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ingress-prod/deployments
.. _Kibana instance: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana
.. _Ingress dashboard: https://grafana.app-sre.devshift.net/d/Av2gccIZk/ingress?orgId=1
