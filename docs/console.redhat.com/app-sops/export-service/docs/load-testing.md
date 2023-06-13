## Export Service Load Testing

Load testing is performed via the export_service IQE suite of tests at: https://gitlab.cee.redhat.com/insights-qe/iqe-export-service-plugin/

### Test Setup

Information on setting up the test environment and getting authenticated is in the [IQE README](https://gitlab.cee.redhat.com/insights-qe/iqe-export-service-plugin/-/blob/main/README.md).

### Running the tests

After setting up the test environment, running the tests, say against stage are performed like so:

    $ export ENV_FOR_DYNACONF=stage_proxy
    $ iqe tests plugin export_service -k test_load_stress

The number of concurrent clients and the number of requests each client sends can be controlled with the `NUM_CLIENTS` & `QUERIES_PER_PROCESS` environment variables.  For example to run 50 concurrent clients sending 100 requests each, run:

    $ export NUM_CLIENTS=50
    $ export QUERIES_PER_CLIENT=100
    $ iqe tests plugin export_service -k test_load_stress

