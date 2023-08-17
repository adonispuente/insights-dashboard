# Playbook Dispatcher Kafka Latency

## SLI description

We're measuring the percentage of the time when there is less than 10000 messages waiting to be processed by our validator and response consumer.
We intend to have this percentage value to be at least 95% over a month (28 days).

## SLI Rationale

The main objective of Playbook Dispatcher is to allow our customers to dispatch a playbook run request and to track the progress of the run.
The tracking of the playbook runs happen over kafka, hence, this SLI codifies the user expectation as a high percentage of fast kafka message processing is a sign of good health.

## Implementation details

We are using the `quantile_over_time` with our `playbook_dispatcher:consumer_group_lag:sum` metric as the base for this SLO.
The `playbook_dispatcher:consumer_group_lag:sum` metric gives us the sum of the messages waiting to be processed (kafka lag) at a particular point in time.
Finally, using `quantile_over_time` we calculate the percentage of messages that are waiting to be processed at any given time.

## SLO Rationale

We acknowledge that a 5% slow Kafka message processing over a month may seem high, but we hope this will account for occational issues within kafka as well as the AWS S3 service that we reach out to fetch archives when processing each messsage.

## Alerts

The `PlaybookDispatcherSLOLatencyKafka` alert in the following prometheus rules file is associated with this latency SLO:
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/playbook-dispatcher/playbook-dispatcher.prometheusrules.yaml
