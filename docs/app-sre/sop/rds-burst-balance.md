# RDS burst balance getting exhausted

## Severity: High

## Impact

Applications using this DB will soon have issues

## Summary

The db instance is using a General Purpose EBS volume and it is sustaining a load the is higher than its baseline performance (3 IOPS per Gb). It is using its burst credits to be able to cope with the current app needs but if the application continues to use it at this pace, the balance will go to zero and the volume will only be able to serve at its baseline performance. At that very moment, the application will be impacted.

## Access required

AWS account associated to the instance

## Steps

* Log in the corresponding AWS account console
* In the admin page of the corresponding db instance, go to the Monitoring tab
* Gather Read IOPS, Write IOPS, Read Latency and Write Latency. A screen capture will be the best option here.
* Contact the development team of the application using the database to investigate this.

## Further info

General Purpose EBS volumes are not straight forward to understand. The [storage section](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html) from the AWS RDS documentation is a great starting point. This [RDS blog entry](https://aws.amazon.com/es/blogs/database/understanding-burst-vs-baseline-performance-with-amazon-rds-and-gp2/) offers a lot of insights to get the full picture.

## Notes

This alert is being changed from a catch-all alert to a per-resource alert as part of https://issues.redhat.com/browse/APPSRE-4750:

https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/36114

The alert will cause a Jira ticket to be created on a tenant's board.

### Disabling the alert

If you want to disable this alert you can do so by adding a label to your
namespace with this format `rds_predict_out_of_burst_balance_{DB_IDENTIFIER}`.
You can find an example [here](https://gitlab.cee.redhat.com/service/app-interface/blob/cf26f45c1788bade0232f7d834aacdc511d31e96/data/services/insights/patchman/namespaces/patchman-engine-prod.yml#L6)
and the skip logic [here](https://gitlab.cee.redhat.com/service/app-interface/blob/d2f07913fd44462222fb79b23f5bfd69f341a90d/resources/observability/cloudwatch-exporter/prometheusrules/cloudwatch-exporter-templated.prometheusrules.yaml.j2#L45). The `DB_IDENTIFIER`
is the `identifier` field used in `externalResources`:

```
externalResources:
- provider: aws
    ...
  - provider: rds
    identifier: DB_IDENTIFIER
    ...
```
