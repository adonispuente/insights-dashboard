# Scaling Hypershift clusters

In contrast to OSD clusters, Hypershift clusters can not be scaled by increasing the nodes attribute in the cluster spec. The reason is, that Hypershift has a different implementation for machine pools than OSD/ROSA Classic clusters. It does not have the concept of a default machine pool. Thus you need to scale the cluster by scaling the machine pool.

Example, machine pool scaling:

```yaml
machinePools:
- id: workers
  instance_type: m5.xlarge
  replicas: 2
  subnet: subnet-0031fb992
```

The machine pool `workers` is created for every hypershift cluster. If multi az is enabled, the cluster will have multiple machine pools, named workes-1...n. 

