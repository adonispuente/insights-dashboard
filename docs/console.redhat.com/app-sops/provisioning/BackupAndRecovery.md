# Data Backup and Recovery

## Redis
Redis is only used for caching, the data stored there can be lost at any time, no backup or recovery is needed.

## RDS
To create a backup of our database, see the [SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/aws/sop/create-rds-instance-from-snapshot.md)

To recover from a backup see [Restore RDS database to a specific point in time](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/aws/sop/restore-rds-instance-to-specific-point-in-time.md)
