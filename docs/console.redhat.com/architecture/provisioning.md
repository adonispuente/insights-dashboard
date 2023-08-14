# Launch Architecture

Provisioning is aiming to quickly and painlessly Launch systems in Customer's infrastructure.

It is launching images build by Image Builder and thus it is tightly connected to it.

## Components diagram

This is documented in an architecture pages for the service and will be kept up to date there:
https://satellite-services.pages.redhat.com/architecture/docs/07_deployment_view.html

## Routes

* No console.redhat.com UI (React) routes are exposed (only React components).
* API Routes
  * [<consoleDot>/api/provisioning/](https://developers.redhat.com/api-catalog/api/launch)

## Dependencies

Hard dependencies:

* **Integrations** - without Integrations (Sources) Customers can't access their connected cloud accounts and Launch into these.
* **Image Builder UI** - our UI is integrated into Image Builder's and not usable without it.
* **Image Builder API** - we retrieve information about the images to be Launched and can't Launch images without it.
* **RBAC** - we deny access for unauthorized users and without RBAC, we can not determine access, so we deny it.

Soft dependencies:

* **Notifications** if notifications are down, we do not deliver notifications :)

## Service diagram

https://satellite-services.pages.redhat.com/architecture/docs/06_runtime_view.html

## Application Success Criteria

* Customers Launching freshly built images to verify them.
* At least 25% freshly built cloud images to be Launched through our service in a year.

## State

All master data are stored in AWS RDS PostgreSQL database provided through app-interface.
The app is not storing any long term customer data,
losing data here means just temporary disruption of currently processed reservations and losing an audit trail of past reservations.

Some data are exported for statistical purposes to S3.
If these are lost, we lose our statistics, but no disruption to the business.

## Load Testing

Load testing hasn't been performed, but will be before SRE transition period is over.

## Resources Consumption

Current memory consumption is ~60 MB and ~0.01 CPU per pod replica.  With 3 replicas for the api and 3 for the worker and one for Integration availability status processing, total memory usage is about 420 MB and about 0.07 CPU. There are slight spikes when the floorist data collector job runs (as it is separate pod).

Over the next year the current feature set will likely not cause an increase in resources.
There are limits applied to all pods that are set to a 5-10 times the expected consumption.
Limit for pod is 600Mi memory and 0.5 CPU.

This is current usage in production with some traffic:

|**Resource type** | **Used** | **Max in namespace**
|limits.cpu        | 4        | 6
|limits.memory     | 4800Mi   | 24Gi
|requests.cpu      | 800m     | 3
|requests.memory   | 800Mi    | 12Gi
