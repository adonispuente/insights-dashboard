# SOP : ACS Fleet Manager

- [SOP : ACS Fleet Manager](#sop--acs-fleet-manager)
  - [ACS Fleet Manager Down](#acs-fleet-manager-down)
    - [Impact](#impact)
    - [Summary](#summary)
    - [Access required](#access-required)
    - [Steps](#steps)
  - [ACS Fleet Manager availability](#acs-fleet-manager-availability)
    - [Impact](#impact-1)
    - [Summary](#summary-1)
    - [Access required](#access-required-1)
    - [Steps](#steps-1)
  - [ACS Fleet Manager latency](#acs-fleet-manager-latency)
    - [Impact](#impact-2)
    - [Summary](#summary-2)
    - [Access required](#access-required-2)
    - [Steps](#steps-2)
  - [ACS Fleet Manager reconciler failure](#acs-fleet-manager-reconciler-failure)
    - [Impact](#impact-3)
    - [Summary](#summary-3)
    - [Access required](#access-required-3)
    - [Steps](#steps-3)
  - [ACS Fleet Manager reconciler long duration](#acs-fleet-manager-reconciler-long-duration)
    - [Impact](#impact-4)
    - [Summary](#summary-4)
    - [Access required](#access-required-4)
    - [Steps](#steps-4)
  - [ACS Central provisioning latency](#acs-central-provisioning-latency)
    - [Impact](#impact-5)
    - [Summary](#summary-5)
    - [Access required](#access-required-5)
    - [Steps](#steps-5)
  - [ACS Central provisioning correctness](#acs-central-provisioning-correctness)
    - [Impact](#impact-6)
    - [Summary](#summary-6)
    - [Access required](#access-required-6)
    - [Steps](#steps-6)
  - [ACS Central deletion correctness](#acs-central-deletion-correctness)
    - [Impact](#impact-7)
    - [Summary](#summary-7)
    - [Access required](#access-required-7)
    - [Steps](#steps-7)
  - [ACS Central timeout](#acs-central-timeout)
    - [Impact](#impact-8)
    - [Summary](#summary-8)
    - [Access required](#access-required-8)
    - [Steps](#steps-8)
  - [ACS Rotate Central UI endpoint certificates](#acs-rotate-central-tenant-certificate)
    - [Impact](#impact-9)
    - [Summary](#summary-9)
    - [Access required](#access-required-9)
    - [Steps](#steps-9)
  - [ACS Gitops Failure](#acs-gitops-failure)
    - [Impact](#impact-10)
    - [Summary](#summary-10)
    - [Access required](#access-required-10)
    - [Steps](#steps-10)
  - [Escalations](#escalations)

---

## ACS Fleet Manager Down

### Impact

No incoming request can be received or processed.
The existing registered ACS Centrals will not be able to be processed.
The ACS Centrals statuses will not be retrieved from OCM and updated to ACS Fleet Manager database.

### Summary

ACS Fleet Manager (all the replicas or pods) are down.

### Access required

- OSD console access to the cluster that runs the ACS Fleet Manager.
- Access to cluster resources: Pods/Deployments/Events

### Steps

- Check Deployments/acs-fleet-manager: check details page to make sure pods are configured and started; make sure pod number is configured to default: 3.
- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact ACS Fleet Manager API.
    - Search Error/exception events with keywords "ACS Fleet Manager " and with text "image", "deployment" etc.
- Investigate the metrics in Grafana for any possible evidences of the crash.
    - Application: Volume, Latency, Error
        - Stage: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1&from=now-28d&to=now&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
        - Production: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1
    - CPU, Network, Memory, IO
        - Stage: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
        - Production: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1
- Check [openshift deployment template](https://github.com/stackrox/acs-fleet-manager/blob/main/templates/service-template.yml) for potential issue cause.
- Check [ACS Fleet Manager CI job logs](https://ci.ext.devshift.net/job/stackrox-acs-fleet-manager-gh-build-main/) for potential error cause.
- If necessary, escalate the incident to the corresponding teams.
    - Check [Escalations](#escalations) section below.

---

## ACS Fleet Manager availability

### Impact

Users are getting numerous amount of errors on API requests.

### Summary

ACS Fleet Manager is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- Access to cluster resources: Pods/Deployments

### Steps

- Investigate the metrics in Grafana for any possible cause of the issue
    - Application: Volume, Latency, Error
        - Stage: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1&from=now-28d&to=now&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
        - Production: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1
    - CPU, Network, Memory, IO
        - Stage: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
        - Production: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc.), increase the number of replicas.
- Check Deployments/acs-fleet-manager, check details page to make sure pods are configured and started. Start the pod if none is running (default:3).
- Check if the ACS Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <acs-fleet-manager-stage|acs-fleet-manager-production>

    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running

    # Check the pod logs to investigate possible causes of the issue (e.g. look for any Error/Exception messages)

    oc logs acs-fleet-manager-<pod_id>  | less
- If necessary, escalate the incident to the corresponding teams.
    - Check [Escalations](#escalations) section below.

---

## ACS Fleet Manager latency

### Impact

ACS Fleet Manager service is experiencing latency, or has been downgraded.

### Summary

ACS Fleet Manager is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- Access to cluster resources: Pods/Deployments

### Steps

refer to the steps in [ACS Fleet Manager availability](#acs-fleet-manager-availability)

---

## ACS Fleet Manager reconciler failure

### Impact

The tenants affected by the failed reconciliations experience degraded service functions.
The level of impact and visibility depends on the type of reconciliation.

### Summary

ACS Fleet Manager encountered reconciliations with a long duration.

### Access required

- OSD console access to the cluster that runs the ACS Fleet Manager.
- Access to cluster resources: Pods/Deployments/Events.
- Access to ACS Fleet Manager logs.

### Steps

- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact ACS Fleet Manager API.
  - Search error/exception events with keywords "ACS Fleet Manager" and with text "reconcile".
  - Identify the ACS tenants that are affected by the reconciliation failure.
- Investigate the metrics in Grafana for any possible evidences of the failure.
  - Application: Volume, Latency, Error
    - Stage: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1&from=now-28d&to=now&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
    - Production: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1
  - CPU, Network, Memory, IO
    - Stage: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
    - Production: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1
- Check [OpenShift deployment template](https://github.com/stackrox/acs-fleet-manager/blob/main/templates/service-template.yml) for potential causes.
- Check [ACS Fleet Manager CI job logs](https://ci.ext.devshift.net/job/stackrox-acs-fleet-manager-gh-build-main/) for potential error cause.
- If necessary, escalate the incident to the corresponding teams.
  - Check [Escalations](#escalations) section below.

---

## ACS Fleet Manager reconciler long duration

### Impact

The tenants affected by the long duration reconciliations experience degraded service functions.
The level of impact and visibility depends on the type of reconciliation.

### Summary

ACS Fleet Manager encountered reconciliations with a long duration.

### Access required

- OSD console access to the cluster that runs the ACS Fleet Manager.
- Access to cluster resources: Pods/Deployments/Events.
- Access to ACS Fleet Manager logs.

### Steps

- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact ACS Fleet Manager API.
  - Search error/exception events with keywords "ACS Fleet Manager" and with text "reconcile".
  - Identify the ACS tenants that are affected by the long reconciliation duration.
  - Confirm if the reconciliations are stuck permanently or exit eventually.
- Investigate the metrics in Grafana for any possible evidences of the duration.
  - Application: Volume, Latency, Error
    - Stage: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1&from=now-28d&to=now&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
    - Production: https://grafana.app-sre.devshift.net/d/T2kek3H9a/acs-fleet-manager-slos?orgId=1
  - CPU, Network, Memory, IO
    - Stage: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=acs-fleet-manager-stage
    - Production: https://grafana.app-sre.devshift.net/d/D1C839d82/acs-fleet-manager?orgId=1
- Check [OpenShift deployment template](https://github.com/stackrox/acs-fleet-manager/blob/main/templates/service-template.yml) for potential causes.
- Check [ACS Fleet Manager CI job logs](https://ci.ext.devshift.net/job/stackrox-acs-fleet-manager-gh-build-main/) for potential error cause.
- If necessary, escalate the incident to the corresponding teams.
  - Check [Escalations](#escalations) section below.

---

## ACS Central provisioning latency

### Impact

ACS Fleet Manager service is experiencing issue while provisioning ACS centrals.

### Summary

ACS Fleet Manager is not able to perform acs central provisioning normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- - OSD Console access to the cluster that runs the Fleetshard-sync service.
- Access to cluster resources: Pods/Deployments/Events

### Steps

- Check if the ACS Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <acs-fleet-manager-stage|acs-fleet-manager-production>

    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running

    # Check the pod logs to investigate possible causes of the latency: look for Error/Exception message.

    oc logs acs-fleet-manager-<pod_id>  | less
    ```
  check the log to ensure Fleet Manager worker is started: there is exactly one Fleet Manager leader running.
    ```
    oc logs <pod-name> | grep 'Running as the leader.*FleetManager'

    You should see output similar to the below from either one of the pods:
    "Running as the leader and starting worker *workers.Worker"
    ```
- Check if the Fleetshard-sync services pods are running and verify the logs.
    ```
    #example
    oc get pods -n <fleetshard-sync-stage|fleetshard-sync-production>

    fleetshard-sync-<pod_id>   1/1     Running

    # Check the pod logs to investigate possible causes of the latency: look for Error/Exception message.

    oc logs fleetshard-sync-<pod_id>  | less
    ```
  check the log to ensure Fleetshard-sync is started and reconcile loops start for requested centrals.
    ```
    oc logs <pod-name> | grep 'Start reconcile central'

    You should see output similar to the below:
    "Start reconcile central <central_name>"
    ```
- How to handle:
    - Error/exception appears related to Fleet Manager API or no leader worker is running, try to restart the pods.
    - Error/exception appears related to Fleetshard-sync check with ACS team Data Plane support.
    - Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team.

---

## ACS Central provisioning correctness

### Impact

ACS Fleet Manager service is experiencing issue while provisioning ACS centrals.

### Summary

ACS Fleet Manager is not able to provision ACS centrals correctly.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- OSD Console access to the cluster that runs the Fleetshard-sync service.
- Access to cluster resources: Pods/Deployments

### Steps

refer to the steps [ACS Central provisioning latency](#acs-central-provisioning-latency)

---

## ACS Central deletion correctness

### Impact

ACS Fleet Manager service is experiencing issue while deleting ACS centrals.

### Summary

ACS Fleet Manager is not able to performing ACS central deletion correctly.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- OSD Console access to the cluster that runs the Fleetshard-sync service.
- Access to cluster resources: Pods/Deployments

### Steps

refer to the steps [ACS Central provisioning latency](#acs-central-provisioning-latency)

---

## ACS Central timeout

### Impact

ACS Fleet Manager service couldn't provision central before the timeout.

### Summary

ACS Fleet Manager service couldn't provision central before the timeout.

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- OSD Console access to the cluster that runs the Fleetshard-sync service.
- Access to cluster resources: Pods/Deployments

### Steps

refer to the steps [ACS Central provisioning latency](#acs-central-provisioning-latency)

---

## ACS rotate Central tenant certificate

### Impact

If not rotated before expiration, ACS tenant UI returns invalid TLS certificates.

### Summary
ACS Fleet Manager service provides TLS key and certificate for managed ACS central tenant UI endpoints. This certificate is a wildcard certificate with CN: `*.acs.rhlcoud.com` or `*.acs-stage.rhcloud.com`. The certificates are valid for a year. This SOP describes how to rotate the certificate before it expires.
### Access Required

- App interface Vault ([Prod](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/prod)/[Stage](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/stage))
### Steps

1. Grab the .tls key for your environment from app-interface vault (VPN required)
    - [Prod](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/prod/service/dataplane-certificate)
    - [Stage](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/stage/service/dataplane-certificate)
    - Store it in a file `tls.key`
1. Create a CSR
    ```
    openssl req -new -key tls.key -out tls.csr

    Country Name (2 letter code) []:US
    State or Province Name (full name) []:North Carolina
    Locality Name (eg, city) []:Raleigh
    Organization Name (eg, company) []:Red Hat\, Inc.
    Organizational Unit Name (eg, section) []:
    Common Name (eg, fully qualified host name) []:*.acs.rhcloud.com or *.acs-stage.rhlcoud.com depending on the environment
    Email Address []:rhacs-eng-ms@redhat.com
    ```
1. Create a service now ticket using [this Form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=e5fc3a19db0898149693cf5e13961975&sysparm_category=bce7f09b4fa25b40220104c85210c7a0&sc_catalog=1a98389b4fa25b40220104c85210c7d4)
    - Select application ID ACSC-001: Red Hat Advanced Cluster Security (Managed Service)
    - Select ticket of reference, for prod: `RITM1256415` , for stage: `RITM1245441`
    - Fill additional Information with:
      ```
      We (RHACS Cloud Service) have an existing wildcard Digicert certificate, issued by Red Hat IT, which needs to be rotated.
      The request here is for new certificates for our <environment> environment. The domain is:
      
      <domain>

      The existing certificates will need to continue to be valid while we switch to the new certificates.

      The .csr is attached to this ticket.
      ```
    - Attach the .csr file to the ticket
1. Wait for cert to be attached to the ticket and download the zip file
1. Unzip the certificates and generate the tls.crt file
    ```
    unzip <zip-file-name> 
    cat ./<unzipped_folder/star_acs[-stage]_rhcloud_com.pem DigiCertCA2.pem > tls.crt       
    ```
1. Validate certificate:
    - Check that cert, key and csr have the same checksum
      ```
      openssl req -pubkey -in tls.csr -noout | openssl sha256
      openssl x509 -pubkey -in star_acs_rhcloud_com.pem -noout | openssl sha256
      openssl pkey -pubout -in tls.key | openssl sha256
      ```
    - Check that dates are valid
      ```
      openssl x509 -noout -in tls.crt -dates

      Output: 
      notBefore=Jun 16 00:00:00 2023 GMT
      notAfter=Jun 18 23:59:59 2024 GMT
      ```
    - Check that domains is correct
      ```
      cat tls.crt | openssl x509 -text | grep DNS
      
      Output:
      DNS:*.acs.rhcloud.com
      ```
1. Put content of `tls.crt` as new secret version in app-interface vault ([Prod](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/prod/service/dataplane-certificate)/[Stage](https://vault.devshift.net/ui/vault/secrets/app-interface/show/acs-fleet-manager/stage/service/dataplane-certificate))
1. Change the secret version reference in acs-fleet-manager configuration ([Prod](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/acs-fleet-manager/namespaces/acs-fleet-manager-production-app-sre-prod-04.yml?ref_type=heads#L37)/[Stage](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/acs-fleet-manager/namespaces/acs-fleet-manager-stage.yml#L37))

## Status page

The ACS cloud service publishes its operational status under `console.redhat.com` + `Red Hat Advanced Cluster Security Cloud Service`
on [status.redhat.com](https://status.redhat.com). The status page integration is managed via app-interface as documented by the
[dev-guidelines](https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/statuspage/).

The ACS status page currently displays a hard coded status, which defaults to `operational`. In case of an incident, the incident commander
should [update the status page](https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/statuspage/#define-a-status) depending
on the nature of the incident:

* `operational`
* `under_maintenance`
* `degraded_performance`
* `partial_outage`
* `major_outage`

The status level during an incident is based primarily on the level of customer impact. Ultimately all parties involved
in the incident handling determine the appropriate status. Some examples include:

- ACS fleet manager is slow to respond to requests in relation to its latency targets.
  - Status `degraded_performance` makes sense here.
- A single ACS Central tenant is down.
  - Status `partial_outage` makes sense here.
- ACS fleet manager does not respond at all to requests.
  - Status `major_outage` makes sense here.
- ACS fleet manager or services it depends on are under maintenance
  - Status `under_maintenance` makes sense here.

Example of merge request modifying the status can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/55703).

---

## ACS Gitops Failure

### Impact

ACS Fleet Manager service is experiencing issue while provisioning or updating ACS centrals.

### Summary

ACS uses a gitops approach for installing different versions of the operator, as well as to configure central instances. 

- The GitOps configuration is a file that is mounted on the
  FleetManager service via a configMap.
- The repository containing the configuration is here https://gitlab.cee.redhat.com/stackrox/acs-cloud-service/config.
- This configmap is created
in the DataPlane here https://gitlab.cee.redhat.com/lcleroux/app-interface/-/blob/master/data/services/acs-fleet-manager/cicd/saas-configmap.yaml. 
- The kubernetes volume specification is here
https://github.com/stackrox/acs-fleet-manager/blob/13173682ac1eca660a13843601a55a46292ded4d/templates/service-template.yml#L1066. 

### Access required

- OSD Console access to the cluster that runs the ACS Fleet Manager.
- OSD Console access to the cluster that runs the Fleetshard-sync service.
- Access to cluster resources: Pods/Deployments

### Steps

- Check if the ACS Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <acs-fleet-manager-stage|acs-fleet-manager-production>

    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running
    acs-fleet-manager-<pod_id>   1/1     Running

    # Check the pod logs to investigate possible causes of the latency: look for Error/Exception message.

    oc logs acs-fleet-manager-<pod_id>  | less
    ```
  check the reported logs to ascertain the root cause of the issue.
  The configuration file might be missing, or invalid.

--- 

## Escalations

- For RDS disaster recovery follow [ACS Fleet Manager instructions](https://github.com/stackrox/acs-fleet-manager/tree/main/docs/architecture#data-continuity-and-disaster-recovery)
- Error/exception appears related to ACS Fleet Manager API or no leader worker is running, try to restart the pods.
- Error/exception related to OCM, check with OCM support to see if they've received OSD cluster request.
- Error/exception events found in the OSD cluster level, check with OCM support.
- Error/exception related to SSO outage, check with CIAM team.
- Error/exception related to fleetshard-sync, check with ACS team or Data Plane support.
- Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team
