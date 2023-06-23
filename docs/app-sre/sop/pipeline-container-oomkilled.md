# Pipeline Containers Being OOMKilled

## Procedures

- [Query](https://prometheus.appsrep05ue1.devshift.net/graph?g0.expr=kube_pod_container_status_terminated_reason%7Breason%3D%22OOMKilled%22%2C%20namespace%3D~%22.*-pipelines%22%7D%20%3E%3D%201&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=6h) `appsrep05ue1` cluster's prometheus for the containers being OOMKilled terminated. Take note of the pod names.
    - Some of our pipelines run in `appsres03ue1`, if you don't find any container in the above [query](https://prometheus.appsres03ue1.devshift.net/graph?g0.expr=kube_pod_container_status_terminated_reason%7Breason%3D%22OOMKilled%22%2C%20namespace%3D~%22.*-pipelines%22%7D%20%3E%3D%201&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=6h) `appsres03ue1`.

The next steps can be done by the web console or via terminal using the `oc` cli.

### Through the web console
- In the [cluster console](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/search/ns/crc-pipelines?kind=core%7Ev1%7EPod), search for the `Pod` using the pod name in the previous step. If you don't a pod with the exact same name you can use the first part of the pod name to filter the results. i. e.: `ccx-data-f543715efe59ba916a8acf6305e2850328b2a409f02bb67ed4-pod` would become just `ccx-data-`.
- Find the pipeline that defined that pod, a pod is created by a `TaksRun` that is owned by a `PipeLineRun` that is defined by a `Pipeline`. Take note of the pipeline name.

### Through the terminal
- Use the same namespace as the pod in this example the pod was run in `crc-pipelines`:
```bash
oc project crc-pipelines
```
- Look up the `Pod` owner, i. e. for `ccx-dat4fd84d114d19e4d7a8923e98838c5529de07b002b6675db61bf2-pod`:
```bash
$ oc get pods -o json ccx-dat4fd84d114d19e4d7a8923e98838c5529de07b002b6675db61bf2-pod | jq .metadata.ownerReferences
[
  {
    "apiVersion": "tekton.dev/v1beta1",
    "blockOwnerDeletion": true,
    "controller": true,
    "kind": "TaskRun",
    "name": "ccx-dat4fd84d114d19e4d7a89246262d10708a-push-deploy-event-to-db",
    "uid": "03361b15-3260-4a23-9b2c-f0e1d2992a1c"
  }
]
```
- Using the information above find the `TaskRun` owner
```bash
$ oc get TaskRun -o json ccx-dat4fd84d114d19e4d7a89246262d10708a-push-deploy-event-to-db | jq .metadata.ownerReferences
[
  {
    "apiVersion": "tekton.dev/v1beta1",
    "blockOwnerDeletion": true,
    "controller": true,
    "kind": "PipelineRun",
    "name": "ccx-data-pipeline-clowder-app-sre-stage-202306141441",
    "uid": "c326dcd3-9f23-4bee-b763-65c28c4fa6f9"
  }
]
```
- Now get `Pipeline` name
```bash
$ oc get PipelineRun -o json ccx-data-pipeline-clowder-app-sre-stage-202306141441 | jq '.metadata.labels."tekton.dev/pipeline"'
"o-openshift-saas-deploy-ccx-data-pipeline-clowder"
```

The next steps are independent of where you found the `Pipeline` name

- In `app-interface` search for a saas-file with name equals the `Pipeline` name minus `o-openshift-saas-deploy-`. i. e. `o-openshift-saas-deploy-ccx-data-pipeline-clowder` is defined by the saas file with `name: ccx-data-pipeline-clowder`.
- Compare `deployResources` in the saas file with our [default value](https://gitlab.cee.redhat.com/service/app-interface/-/blob/051facc49398c4815332363c079d99cd5f575770/data/pipelines/tekton-provider-global-defaults.yaml#L56) if current deployResources is smaller than default, then remove deployResources section, otherwise bump memory limit.

### Stopping the alert

When you are finished you can delete the pods that where OOMKilled in order to make the alert go away.

```bash
oc delete pod <pod-name> [<more-pod-names>]
```
