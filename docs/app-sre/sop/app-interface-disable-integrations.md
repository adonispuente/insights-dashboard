# Disable qontract-reconcile integrations for specific resources

To disable an integration from running on specific resources, the following section should be added to the resource file:

```yaml
disable:
  integrations:
  - openshift-users
```

Available options:

- Cluster:
    * disable `integrations`
    * [schema](https://github.com/app-sre/qontract-schemas/blob/f4181f975753f31b7582802b2bee6150668a3551/schemas/openshift/cluster-1.yml#L502-L538)
    * [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/7710f626eb4cb4dd656473cab67b921127433e59/data/openshift/insights/cluster-insights-perf.yml#L28)

- AWS account:
    * disable `integrations`
    * [schema](https://github.com/app-sre/qontract-schemas/blob/f4181f975753f31b7582802b2bee6150668a3551/schemas/aws/account-1.yml#L56-L70)
    * [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/7710f626eb4cb4dd656473cab67b921127433e59/data/aws/osio-dev/account.yml#L23-27)
