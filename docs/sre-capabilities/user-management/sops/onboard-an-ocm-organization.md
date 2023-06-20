# Onboarding an OCM organization with user management

`user management` acts only on OCM organizations that have been explicitely onboarded with the service. This is a requirement for now and might be lifted in the future.

Make sure that the OCM organization belongs to a Red Hat internal team.

### Steps

* Add the new organization ID to the `--ocm-org-ids` `extraArg` of the [qontract-reconcile-ocm-standalone-user-management.yml](data/integrations/qontract-reconcile-ocm-standalone-user-management.yml) integration file.
