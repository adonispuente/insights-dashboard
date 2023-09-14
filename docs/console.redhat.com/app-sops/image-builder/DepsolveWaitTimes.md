# Depsolve wait times

## Impact

When depsolve wait times are too high, image builds will not complete.

## Summary

This alert triggers when there's not enough workers to handle the incoming depsolve jobs. As the
manifest jobs, which are dependent on depsolve jobs, time out after 5 minutes, it's important that
there's enough workers at all times to keep the depsolve wait times low.

## Access required

N/A

## Steps

Monitor the situation, if it does not improve add more workers. It's imperative that the wait
times + the time it takes to complete the depsolve job don't come near 5 minutes.

In case the wait times reach 3 minutes:
1. Increase the worker count by 25% on the
   `resources/terraform/resources/image-builder/production/asg/asg-1.yml` ASG. Increase both the
   `min_size` and `max_size`.
1. Notify the image builder team on slack (@image-builder-team).


Escalations
-----------

See [https://visual-app-interface.devshift.net/services#/services/image-builder/app.yml]([https://visual-app-interface.devshift.net/services#/services/insights/image-builder/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/image-builder/app.yml)
)
