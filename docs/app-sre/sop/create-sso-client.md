# SOP: How to create an auth.redhat.com SSO (single sign-on) client

## Purpose

This SOP describes creating a new SSO client for use with auth.redhat.com.

## Prerequisites

* Installed `qontract-cli` tool (see [qontract-reconcile](https://github.com/app-sre/qontract-reconcile))
* A production app-interface qontract-server config (e.g. `config.prod.toml`)

## Procedure

### Qontract-cli command

The `qontract-cli` tool has a subcommand for managing SSO clients. The subcommand is called `sso-client`.

Use `--help` to get all available commands and options:

```shell
$ qontract-cli --config <PATH_TO_CONFIG_TOML> sso-client --help
Usage: qontract-cli sso-client [OPTIONS] COMMAND [ARGS]...

  SSO client commands

Options:
  --help  Show this message and exit.

Commands:
  create  Create a new SSO client
  remove  Remove an existing SSO client
```

### Create a new SSO client

This command will create a new SSO client with the given name, request URIs, and redirect URIs. Please store the printed SSO client data manually in Vault.

Basic usage:

```shell
$ qontract-cli --config <PATH_TO_CONFIG_TOML> sso-client create --request-uri <HTTPS_URL> --redirect-uri <HTTPS_URL> <CLIENT_NAME>
```

Example:

```shell
$ qontract-cli --config <PATH_TO_CONFIG_TOML> sso-client create --request-uri https://just-an-example.org --redirect-uri https://just-an-example.org/login  just-test
SSO client created successfully. Please save the following JSON in Vault!
{
  "client_id": "1234567890",
  "client_id_issued_at": 1693832008,
  "client_name": "just-test",
  "client_secret": "*****",
  "client_secret_expires_at": 0,
  "grant_types": [
    "authorization_code",
    "refresh_token"
  ],
  "redirect_uris": [
    "https://just-an-example.org/login"
  ],
  "registration_access_token": "****",
  "registration_client_uri": "https://****",
  "request_uris": [
    "https://just-an-example.org"
  ],
  "response_types": [
    "code",
    "none"
  ],
  "subject_type": "public",
  "tls_client_certificate_bound_access_tokens": false,
  "token_endpoint_auth_method": "client_secret_basic",
  "issuer": "https://****"
}
```

> :warning: **Attention**
>
> You need to store the SSO client data in Vault manually. The `qontract-cli` tool does not do any write operations on Vault!



### Remove an SSO client

To remove an SSO client, you must provide the Vault secret path where the SSO client data is stored.

Basic usage:
```shell
$ qontract-cli --config <PATH_TO_CONFIG_TOML> sso-client remove <VAULT_SECRET_PATH>
```

After removing the SSO client, please remove the Vault secret manually!

Example:
```shell
$ qontract-cli --config <PATH_TO_CONFIG_TOML> sso-client remove app-sre/creds/ca-test
SSO client removed successfully. Please remove the secret from Vault!
```
