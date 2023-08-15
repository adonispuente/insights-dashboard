# Disaster recovery

All the application data is stored in the [Postgres database hosted on AWS](./data/services/insights/content-sources/namespaces/content-sources-prod.yml).

To recover the service after a data loss,
1. use the database service (e.g. RDS) data recovery mechanism and
2. re-start the service.

Instructions on recovering an RDS instance from a snapshot are available here: https://gitlab.cee.redhat.com/service/app-interface#create-rds-database-from-snapshot.

# These other sources of data can be lost with no long term consequences
* Kakfa (Only used for notifications)
* Redis (Used for caching rbac permission checks)

## Data loss impact

In case of a complete database data loss, all the repository information is lost.


