# Enforce SSL on an RDS database connections

This SOP explains the process to enforce SSL on RDS databases managed via app-interface.

## Steps

1. Add the `ca_cert` attribute to the RDS definition for which you want to enforce SSL. This will cause an addition of an SSL certificate to the RDS output secret.
    * More information: https://gitlab.cee.redhat.com/service/app-interface#manage-rds-databases-via-app-interface-openshiftnamespace-1yml
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79345
1. Make sure your service has the proper implementation to handle SSL connections (connection string, ssl mode, certificate, etc).
    * This may also require changes to the OpenShift template(s).
    * Hint: don't forget init containers (possibly running database migrations).
1. Update (or create) the RDS parameter group referenced in the RDS definition to add the following parameter:
    ```yaml
    - name: rds.force_ssl
      value: 1
      apply_method: immediate
    ```
    * Make sure your service is promoted with the SSL implementation before enforcing SSL.
    * You may also create a new parameter group file and switch to it instead of updating in place.
    * You may need to approve deletions of parameter groups. More information: https://gitlab.cee.redhat.com/service/app-interface#enable-deletion-of-aws-resources-in-deletion-protected-accounts
    * Examples:
        - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79352
        - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/79359

## Notes

* The parameter group update will happen during the next maintenance window (as defined in the RDS definition's defauls file).
* Tenants may consider updating the `maintenance_window` of the RDS definition (to match any customer notifications, for example), or use `apply_immediately`.
