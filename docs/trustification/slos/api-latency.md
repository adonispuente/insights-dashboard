# Trustification - API latency

## SLI description

Measuring the latency of successful search requests for the following microservices:

* bombastic-api
* vexination-api
* spog-api

The latency of non-search requests are largely dependent on the user input and are therefore not measured.

## SLI Rationale

The Trustification UI is search-driven and therefore the search latency is important for the user experience.

## Implementation details

We record the latency of the HTTP requests of each service into histograms.

## SLO Rationale

The latency is important for the user experience, so the target is that 99% of requests should be performed within 1 second.
