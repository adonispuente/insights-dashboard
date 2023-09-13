# Trustification SLOs

The service consists of multiple microservices that use AWS S3 for storage and AWS SQS for events.

Please see the [Architecture Description](https://docs.google.com/document/d/1VA7VMNcqAbxEQMZSpLEOa7v8u0gHI77PT-TJ9MeuGz8/edit).

## SLIs and SLOs

| | SLI | SLO |
|:-------------:|:-------------|:-------------:|
| [Availability](slos/api-errors.md) | The proportion of successful requests.<br /><br />Any HTTP status other than 500–599 is considered successful.<br /><br /># API requests which do not have a 5XX status code<br />/<br /># API requests | >= 99% success |
| [Latency](slos/api-latency.md) | The proportion of sufficiently fast requests.<br /><br />"Sufficiently fast" is defined as < 1 sec.<br /><br /># Successful API requests with a duration less than [1s]<br />/<br /># Successful API requests | >= 99% of requests are "Sufficiently fast" |
| [Index Availability](slos/indexing-errors.md) | The proportion of documents that failed to index.<br /><br /># Documents that failed to index<br />/<br /># Documents attempted indexed | < 1% success |
