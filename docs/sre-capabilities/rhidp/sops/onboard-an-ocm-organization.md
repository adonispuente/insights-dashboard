# Onboarding an OCM organization with Red Hat SSO IDP

Red Hat SSO IDP acts only on OCM organizations that have been explicitely onboarded with the service. This is a requirement for now and might be lifted in the future.

Make sure that the OCM organization belongs to a Red Hat internal team.

### Steps

* Add the new organization ID to the `--ocm-org-ids` `extraArg` of the [qontract-reconcile-ocm-oidc-idp-standalone.yml](data/integrations/qontract-reconcile-ocm-oidc-idp-standalone.yml) and [qontract-reconcile-rhidp-sso-client-standalone.yml](data/integrations/qontract-reconcile-rhidp-sso-client-standalone.yml) integration config files.
