# Trustification - Indexer Errors

## SLI description

Measuring the number of documents indexed and the number of documents that failed to index for the following microservices:

* bombastic-indexer
* vexination-indexer

The SLI is the rate of errors compared to the total number of documents indexed.

## SLI Rationale

The search index is a real time index that is continuously updated from remote sources. If there are errors during indexing this will impact the quality of the search results.

## Implementation details

We record the number of documents that failed to index, and the number of documents attempted to index.

## SLO Rationale

We want to make sure most documents get ingested successfully. Although some documents may be invalid, they should be few. The target is that less than 1% of documents fail to index.

NOTE: For this service, only we/Red Hat have credentials to ingest documents, so we are in control of this process. So if we happen to insert/ingest bad data this would affect the SLO, but it would be under our control to fix.
