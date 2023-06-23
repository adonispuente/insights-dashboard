# Onboard an OCM organization with AUS

`AUS` acats only on OCM organization that have been explicitely onboarded with the service. This is a requirement for now and might be lifted in the future.

Make sure that the OCM organization belongs to a Red Hat internal team.

### Steps to onboard on org with the OCM label based AUS flavour

* Add the new organization ID to the `--ocm-org-ids` `extraArg` of the [qontract-reconcile-advanced-upgrade-scheduler.yml](data/integrations/qontract-reconcile-advanced-upgrade-scheduler.yml) integration file.


### Steps to onboard an org with the app-interface AUS flavour

* Onboard an org as described [here](docs/app-sre/sop/onboard-ocm-organisation.md)
* consider granting self-service via the [ocm-org-owner](data/app-interface/changetype/ocm-org-owner.yml) change-type
