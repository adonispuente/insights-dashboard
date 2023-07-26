# SOP

## Glitchtip Redis

### Severity: High or Critical

### Impact

Abnormally high memory usage (or item count) may lead to performance degradation or service outage.

### Summary

We've seen in the past high memory usage and high item count in Redis (Elasticache) for Glitchtip. Glitchtip uses Redis as a message broker for all background jobs via Celery.


### Possible causes

* High incoming traffic (new events)
* Celery workers are not running or are too slow
* Celery upgrade issues

### Access required

View access to clusters and namespaces where pods are running in ([glitchtip in visual-app-interface](https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml)).

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Review the logs of the pods to see if there are any errors.
- Start redis debug container
  ```bash
  $ oc login ... && oc project ...
  $ oc process --local -p REDIS_SECRET_NAME=glitchtip-elasticache -f https://raw.githubusercontent.com/app-sre/diag-container/master/openshift.yml | oc apply -f -
  $ oc rsh diag-container-XXXX
  ```
- Scan Redis for big keys.
    ```bash
    $ redis-cli -h $REDISCLI_HOST -p $REDISCLI_PORT --tls --bigkeys
    ```
- Scan Redis for high-memory keys.
    ```bash
    $ redis-cli -h $REDISCLI_HOST -p $REDISCLI_PORT --tls --memkeys
    ```
- Flush all keys - this is generally safe; some alert emails may be lost.
    ```bash
    $ redis-cli -h $REDISCLI_HOST -p $REDISCLI_PORT --tls
    master.glitchtip-redis-stage.blh0c5.use1.cache.amazonaws.com:6379> FLUSHALL
    OK
    ```

### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
