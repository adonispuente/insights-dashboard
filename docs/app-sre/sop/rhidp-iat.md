# Red Hat SSO IDP - Initial Access Token (IAT) Management

## Initial Access Token (IAT) expiration

### Severity: High (prod) / Medium (stage)

### Impact

The Red Hat SSO IDP can no longer create new cluster SSO profiles.

### Summary

The Red Hat SSO IDP uses an Initial Access Token (IAT) to create new cluster SSO profiles. This token expires for
* the prod instance (auth.redhat.com) after 30 days
* the stage instance (stage.auth.redhat.com) after 90 days

The integration cannot create new SSO profiles but can remove existing ones. This means the integration will fail as soon as a new SSO profile needs to be created.

### Access required

The recreation (refresh) of the IAT is currently a manual process and is targeted to be automated in the future ([ITIAM-5412](https://issues.redhat.com/browse/ITIAM-5412)).

### Steps

1. In order to get a new IAT (prod or stage), open a [SNOW ticket (TBD)]() and request one.
1. Use this template to create the ticket:
    ```
    Hi,

    We (AppSRE) need a new Initial Access Token (IAT) for our Red Hat SSO IDP integration. The current one expires on <DATE>.

    Please follow your internal documentation (https://source.redhat.com/groups/public/identity-access-management/it_iam_internal_sso_int_idp_wiki/how_to_create_an_initial_access_token_for_dynamic_client_registration) to create a new one.

    SSO instance: <auth.redhat.com (prod) / auth.stage.redhat.com (stage)>
    Number of clients: 100
    Expiration period: 30 days (prod) / 90 days (stage)

    Please send me the new IAT via burn-after-reading PrivateBin or Bitwarden Send.

    Thank you very much!

    Kind regards,
    AppSRE team
    ```
1. Receive the new IAT and update the corresponding secret in Vault:
   * for prod [app-sre/show/creds/rhidp/auth.redhat.com](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/rhidp/auth.redhat.com)
   * for stage [app-sre/show/creds/rhidp/auth.stage.redhat.com](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/rhidp/auth.stage.redhat.com)


### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
