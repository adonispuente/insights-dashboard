# Trustification - API errors

## SLI description

Measuring the proportion of requests that succeed fail with a non-5xx code for the following microservices:

* bombastic-api
* vexination-api
* spog-api

## SLI Rationale

The HTTP status codes 5xx errors are a good indication if the service is functioning propertly. If a 5xx error occurs, it could be related to critical bugs or external AWS services.

## Implementation details

We count the number of API requests and label them with their status codes. The SLI is collected for each of the bombastic-api, vexination-api and spog-api microservices.

## SLO Rationale

The API availability is critical for the UI to work, so the target is that 99% of requests complete with a non-5xx code.
