## Playbook Dispatcher Load Testing

Load testing is performed via the playbook_dispatcher IQE suite of tests at: https://gitlab.cee.redhat.com/insights-qe/iqe-playbook-dispatcher-plugin/

### Test Setup

Information on setting up the test environment and getting authenticated is in the [IQE README](https://gitlab.cee.redhat.com/insights-qe/iqe-playbook-dispatcher-plugin/-/blob/main/README.md).

### Running the tests

After setting up the test environment, running the tests, say against stage are performed like so:

    $ export ENV_FOR_DYNACONF=stage_proxy
    $ iqe tests plugin playbook_dispatcher -k test_load_stress

The number of concurrent clients and the number of requests each client sends can be controlled with the `NUM_CLIENTS` & `QUERIES_PER_PROCESS` environment variables.  For example to run 50 concurrent clients sending 100 requests each, run:

    $ export NUM_CLIENTS=50
    $ export QUERIES_PER_CLIENT=100
    $ iqe tests plugin playbook_dispatcher -k test_load_stress

### Sample load test results

When running one client sending 100 requests to the five different tested operations, we obtained the following data:

Operation type | Time taken |
--- | --- |
create operation 1 | 0.44951891899108887 |
create operation 2 | 0.4099276065826416 |
create operation 3 | 0.5004265308380127 |
query operation 1 | 0.5377354621887207 |
query operation 2 | 0.5694096088409424 |
**Total** | 2.467018127 |

The Playbook Dispatcher pod was able to serve a total of 500 requests in under 2.5 seconds.

During the test, we also noted the following resource usages:

Resource type | Maximum usage |
--- | --- |
CPU | < 200m |
Memory | ~ 500 MiB |
