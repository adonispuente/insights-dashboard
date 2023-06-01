# Clair v4 - Cloudwatch logs

## Steps
* Log into AppSRE AWS logging account: https://744086762512.signin.aws.amazon.com/console 
* Browse to cloudwatch: https://console.aws.amazon.com/cloudwatch/home
* Select logging group `clairp01ue1.<namespace>`


## Example Queries

### Indexer Errors
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter level = "error"
| sort @timestamp desc
```

### Manifests Indexed
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter message like "manifest successfully scanned"
| sort @timestamp desc
```

### Notifier Errors
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "notifier"
| filter level = "error"
| sort @timestamp desc
| limit 200
```
