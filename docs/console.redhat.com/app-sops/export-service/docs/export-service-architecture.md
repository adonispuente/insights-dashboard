# Export Service - Service Documentation
# Purpose
Export Service is a console.redhat.com microservice that will allow users to request and download data archives for auditing or use with their own tooling. 

# Service Description
The Export Service allows users to request and download data archives for auditing or use with their own tooling. Because many ConsoleDot applications need to export data, this service provides some common functionality. Apps that already have an export feature will be encouraged to migrate to the shared export process for improved visibility and future feature enablement.

# Components
The Export Service is build with Go and uses Kafka for communication with other services. It has a public API that accepts requests for resources from other console.redhat.com services. It then uses the internal API to accept the resources from those services. The resources are stored in S3 and zipped together for download by the user once ready.

# Tenancy
Tenants can onboard to the export service to request data exports and provide data to be exported. This will involve a PSK being added to Export Service to authenticate the data source application. The front-end will authenticate through 3-scale by passing the identity header to Export Service.

# Technology Stack
* Go
* Kafka
* S3 (Minio for local development)
* PostgreSQL

# Routes
## Public API
Used by tenants (via a front-end) requesting exports (Identified by their XRHID header via 3Scale)
### /exports
- POST - Requests a new export
- GET - Returns a list of all exports and their statuses
### /exports/{id}
- GET - Downloads an export (once ready)
- DELETE - Used by a tenant to delete a requested export
### /exports/{id}/status
- GET - Check an export’s status to see if it is ready for download
## Internal API
Used by services to provide data to be exported (In response to a request via kafka message sent from export-service)
### /upload/{id}/{application}/{resource}
- POST - uploads the data file in the requested format (csv, json)
### /error/{id}/{application}/{resource}
- POST - returns an error if the request could not be fulfilled

# Dependencies
- S3
- PostgreSQL
- OpenShift (Vault Secrets, Kafka, ConfigMaps, Services)

# State
The application uses a PostgreSQL database to store the state of the exports. The resource data itself is stored in S3. The application will use Kafka to communicate with other services.

# Load Testing
Load testing is being added as part of [RHCLOUD-25419](https://issues.redhat.com/browse/RHCLOUD-25419).

# Capacity
Required capacity in terms of memory and cpu per pod, and the number of pods. Is this expected to change over time?
- CPU: 500m
- Memory: 512m
Required amount of storage (DB, S3, local, etc). Is this expected to change over time?
- We expect 100GB should last for the foreseeable future.

# [Application Success Criteria](https://docs.google.com/document/d/1_AoqDdY0rClO6EA7vKQGYUdE47UaY9XrdHh4N6DuXsQ/edit?usp=sharing)
# [GitHub Repository](https://github.com/RedHatInsights/export-service-go)