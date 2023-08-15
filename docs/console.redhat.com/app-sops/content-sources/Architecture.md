# Content Sources Architecture

Since we aim to have as much information upstream, we are linking to our [upstream documentation](https://github.com/content-services/content-sources-backend/blob/main/docs/architecture.md) for most architecture information.  This ensures that the documentation is kept in a single place and does become stale.

We will store internal information here.

## Application Success Criteria

* Short Term Success Criteria
  * to be live in a production environment with Image Builder actively using it to build images and customers actively building images with custom content.
* Long Term Success Criteria
  * to support a more premium tier of service, whereby Red Hat and non-Red Hat yum repositories are snapshotted and served to directly to client machines.  This brings functionality we have within our hosted products to a cloud native solution.

## Load Testing

Load testing hasn't been performed, but will be before GA.

## Resources Consumption

Current idle memory consumption is ~30 MB per pod replica.  With 3 replicas for the api and 3 for the kafka consumer, total memory usage is about 180 MB. Current usage cpu usage is 14m.  Every eight hours an introspection cron job runs that temporarily increase total memory usage by another 30 MB and cpu usage may go to ~800m temporarily.

## Capacity Planning

Over the next year we will roll out a pulp server as part of our application in production.  This will increase overall resources quite dramatically.

Based on the current stage deployment (with pulp), we would see it grow to 2-5GB of memory, and 1-6 CPUs.  However, these are preliminary numbers, with large ranges, and we are still learning about the performance patterns of a pulp deployment.
