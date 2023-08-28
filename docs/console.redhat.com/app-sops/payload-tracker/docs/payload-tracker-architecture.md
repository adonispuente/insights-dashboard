# Payload Tracker - Service Documentation

## Purpose
The Payload Tracker is a centralized location for tracking payloads through the Platform. Finding the status (current, or past) of a payload is difficult as logs are spread amongst various services and locations. Furthermore, Prometheus is meant purely for an aggregation of metrics and not for individualized transactions or tracking.

## Service Description
The Payload Tracker aims to provide a mechanism to query for a request_id, inventory_id, or system_uuid (physical machine-id) and see the current, last or previous X statuses of this upload through the platform. In the future, hopefully it will allow for more robust filtering based off of service, account, and status.

The ultimate goal of this service is to say that the upload made it through X services and was successful, or that the upload made it through X services was a failure and why it was a failure.

## Components
Payload Tracker is a service that lives in platform-<env>. This service has its own database representative of the current payload status in the platform. There are REST API endpoints that give access to the payload status. This service listens to messages on the Kafka MQ topic platform.payload-status. There is now a front-end UI for this service located in the same platform-<env>. It is respectively titled "payload-tracker-frontend."

## Tenancy
Simply send a message on the ‘platform.payload-status’ for your given Kafka MQ Broker in the appropriate environment. Currently, the following fields are required:

    org_id
    service
    request_id
    status
    date

```
{ 	
    'service': 'The services name processing the payload',
    'source': 'This is indicative of a third party rule hit analysis. (not Insights Client)',
    'account': 'The RH associated account',
    'org_id': 'The RH associated org id',
    'request_id': 'The ID of the payload (This should be a UUID)',
    'inventory_id': 'The ID of the entity in terms of the inventory (This should be a UUID)',
    'system_id': 'The ID of the entity in terms of the actual system (This should be a UUID)',
    'status': 'received|processing|success|error|etc',
    'status_msg': 'Information relating to the above status, should more verbiage be needed (in the event of an error)',
    'date': 'Timestamp for the message relating to the status above. (This should be in RFC3339 UTC format: "2022-03-17T16:56:10Z")'
}
```
The following statuses are required:
```
‘received‘ 
‘success/error‘ # success OR error
```

## Technology Stack
- Go (Golang)
- Kafka
- PostgreSQL

## Routes
See the [API Specification](https://github.com/RedHatInsights/payload-tracker-go/blob/master/api/api.spec.yaml)

## Dependencies
- PostgreSQL
- OpenShift (Vault Secrets, Kafka, ConfigMaps, Services)

## State
The application uses a PostgreSQL database to store the processing status of the payloads. The application uses Kafka to communicate with other services.

## Load Testing
In progress as part of [RHCLOUD-27490](https://issues.redhat.com/browse/RHCLOUD-27490)

## Capacity
Required capacity in terms of memory and cpu per pod. Not expected to change in the foreseeable future.
- CPU: 500m
- Memory: 512m
Required amount of storage (DB, S3, local, etc).
- We expect 100GB should last for the foreseeable future.

## [Application Success Criteria](https://docs.google.com/document/d/1_syt34SXGkfBsTwyEBQcCXa0H5068cPrT2s_Il28YZQ/edit?usp=sharing)
## GitHub Repositories
[Front-End](https://github.com/RedHatInsights/payload-tracker-go/tree/master)
[Back-End](https://github.com/RedHatInsights/payload-tracker-frontend/tree/master)
