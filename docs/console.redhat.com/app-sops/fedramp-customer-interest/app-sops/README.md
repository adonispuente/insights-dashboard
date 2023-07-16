# SOP : FedRAMP customer interest

- [SOP : FedRAMP customer interest](#sop--fedramp-customer-interest)
  - [FedRAMP customer interest down](#fedramp-customer-interest-down)
    - [Impact](#impact)
    - [Summary](#summary)
    - [Access Required](#access-required)
    - [Steps](#steps)
  - [FedRAMP customer interest availability](#fedramp-customer-interest-availability)
    - [Impact](#impact-1)
    - [Summary](#summary-1)
    - [Access Required](#access-required-1)
    - [Steps](#steps-1)
  - [FedRAMP customer interest latency](#fedramp-customer-interest-latency)
    - [Impact](#impact-2)
    - [Summary](#summary-2)
    - [Access Required](#access-required-2)
    - [Steps](#steps-2)
  - [FedRAMP customer interest ServiceNow incidents](#fedramp-customer-interest-servicenow-incidents)
    - [Impact](#impact-3)
    - [Summary](#summary-3)
    - [Access Required](#access-required-3)
    - [Steps](#steps-3)
  - [Escalations](#escalations)

## FedRAMP customer interest down

### Impact

The FCI service is unavailable due to all pods being down, impacting the overall system availability and functionality.

### Summary

FCI (all the replicas or pods) are down.

### Access Required

- Access to the OpenShift cluster console
- Access to cluster resources: Pods/Deployments/Events

### Steps

1. Check deployment status:
   - Verify the number of `fedramp-customer-interest` deployment replicas. The minimum value is `3`.
     - If the replica's number is less than `3` please check the `REPLICAS` parameter in [SaaS file][saas].
   - Check deployment events to ensure there is no abnormality in the cluster level that could impact FCI.

2. Check pod status:

   - Verify the status of all pods associated with the `fedramp-customer-interest` deployment.
     - All pods must be in `Running` state.
     - Analyze the pod logs for the errors, misconfiguration, application panic.
   - Check deployment events to ensure there is no abnormality in the cluster level that could impact FCI.

3. Restart deployment/pods:

   - If there are no critical issues identified, try to rollout the deployment or restart the pods.
   - Monitor the pod status after the restart to ensure they come up successfully.
   - Check the pods logs to ensure no errors in running application.
     - An example log of a successfully launched application

     ```json
     {"level":"info","timestamp":"2023-07-13T14:15:47.300Z","msg":"Starting server on port :3000"}
     ```

4. If necessary, please, [escalate](#escalations) the incident to the corresponding team.

## FedRAMP customer interest availability

### Impact

This case relates to the FCI returning error status codes more than 10% of the time, indicating a potential issue affecting service reliability.

### Summary

The FCI returns error status codes `(5**)` more than 10% of the time.

### Access Required

- Access to the OpenShift cluster console and Grafana.
- Access to cluster resources: Pods/Deployments/Events

### Steps

1. Please make sure that service is up and running base on the [above procedure](#steps).

2. Check pod metrics (CPU, Network, Memory, IO) in OpenShift console or via Grafana.

   - [Stage dashboard](https://grafana.stage.devshift.net/goto/2TUT81C4z?orgId=1)
   - [Production dashboard](https://TODO)

3. Identify errors status codes and error patterns like frequency and distribution of identified error codes.

4. Analyze application logs for error messages or exceptions.

5. If necessary, please, [escalate](#escalations) the incident to the corresponding team.

## FedRAMP customer interest latency

### Impact

FCI service is experiencing latency, or has been downgraded.

### Summary

FCI is not performing normally and is not able to handle the load.

### Access Required

- Access to the OpenShift cluster console and Grafana.
- Access to cluster resources: Pods/Deployments/Events

### Steps

1. Please refer to the [availability section](#fedramp-customer-interest-availability)
2. If necessary, please, [escalate](#escalations) the incident to the corresponding team.

## FedRAMP customer interest ServiceNow incidents

### Impact

This case refers to the situation where at least 10% of the requests made to the FedRAMP customer interest result in failures within the last 5 minutes.

### Summary

FCI is not performing normally specifically when at least 10% of requests fail within the last 5 minutes.

### Access Required

- Access to the OpenShift cluster console and Grafana.
- Access to cluster resources: Pods/Deployments/Events

### Steps

1. Please refer to the [availability section](#fedramp-customer-interest-availability).
2. Analyze the application logs for the potential issues when interacting with the ServiceNow or OCM API's.

   - Most user interaction errors are checked by backend before the request is sent to ServiceNow API.
But we still might encounter errors like request execution timeout, OCM API inaccessibility and ServiceNow API inaccessibility.
3. If necessary, please, [escalate](#escalations) the incident to the corresponding team.

## Escalations

[Escalation policy](https://visual-app-interface.devshift.net/services#/services/insights/fedramp-customer-interest/app.yml)

[saas]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/fedramp-customer-interest/deploy.yml
