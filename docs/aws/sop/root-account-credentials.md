# AWS root account password and two-factor authentication (2FA)

[TOC]

## Context

AWS root account password is stored in Vault in a separate engine that's accessed through a break-glass type procedure. We don't need further redundancy since it can be reset via AWS email password recovery method that will be described in this document.

The accounts have 2FA authentication. We will associate two different 2FA TOTP provides (Vault and BitWarden) for redundancy purposes since AWS allow to have multiple MFA devices associated.

## Access required

### Vault aws-root-accounts engine

The access to the Vault aws-root-accounts engine where credentials are stored is operated in a break-glass way. In order to gain access to it:

* Make sure no other user has the `/teams/app-sre/roles/aws-root-accounts.yaml` associated to their user profile.
* Assign it to your user profile in app-interface.
* Log in Vault:
    ```
    vault login -method=oidc -address=https://vault.devshift.net
    ```

**IMPORTANT**: Make sure that the role `/teams/app-sre/roles/aws-root-accounts.yaml` is not assigned to you after you're done getting/setting root account credentials.

### AppSRE passwords collection in RedHat's BitWarden

**NOTE**: This is actually only needed if you need to set 2FA in an account.

* Log in BitWarden's Vault: https://vault.bitwarden.com/
* Make sure you can see the "AppSRE passwords" collection in RedHat's BitWarden.
* If not, you will need to ask in the AppSRE team for access to the "appsre-passwords" Rover collection: https://rover.redhat.com/groups/group/appsre-passwords

## Get root account password

Root password for an account `<account-name>` can be retrieved from Vault:

```
vault kv get aws-root-accounts/<account-name>
```

**NOTE**: Make sure you update the root account password once you're done using it (see below procedure).

## Get root account two factor authentication

### Vault

A 2FA code password for an account `<account-name>` can be retrieved from Vault:

```
vault read totp/aws-root-accounts/code/<account-name>
```

### BitWarden

You can get a 2FA from RedHat's BitWarden's Vault in the AppSRE collection. An entry should exist for the account you want to log in and you can get a code by right-clicking in the three dots in the corresponding UI line.

## Set root account password and 2FA

We'll use the password recovery mechanism for this. It is mandatory that you have access to the email associated to the account.
First, take a look at the `accountOwners[0].email` reference in app-interface like [this one](https://gitlab.cee.redhat.com/service/app-interface/-/blob/8c19ffb74195a73640fdab6f39ce294610fed548/data/aws/cna-service/account.yml#L18). If that email doesn't work, try the following patterns:

- `sd-app-sre+<account-name>@redhat.com`
- `sd-app-sre+aws-<account-name>@redhat.com`

Further, check your gmail history with the account name and account id - the email address should appear in there somewhere.

### Root account password

* Use the console url to log in.
* Click in the "Sign in using root user email" option.
* Try to log in with the root email and then click in the "Forgot Password?" link.
* An email will be sent to the email account and you can continue the process from there.
* Make sure that you generate a good password: 24 characters is a good starting point.
* Store the email and the password in a secret in the [`aws-root-accounts`](https://vault.devshift.net/ui/vault/secrets/aws-root-accounts/list) Vault folder.

### Two-factor authentication

* Use the console url to log in.
* Click in the "Sign in using root user email" option.
* Go to IAM section.
* In the IAM dashboard click in "My security credentials" quick link that you should see in the right part of the screen.

#### BitWarden 2FA

* Click in Assign MFA.
* Device name is `bitwarden-<account-name>`.
* Select Authenticator app MFA device type.
* Copy secret key shown in "Show secret key"
* Log into BitWarden https://vault.bitwarden.com/#/login.
* Create a new item under "Appsre Passwords" BitWarden collection called `AWS account <account-name> root user`.
* Fill the "Authenticator key (TOTP)" with the secret key and save it.
* Add two consecutive verification codes in the AWS MFA page (you can get them by clicking in the three dots in BitWarden)

#### Vault 2FA

* Click in Assign MFA.
* Device name is `vault-<account-name>`.
* Select Authenticator app MFA device type.
* Read the QR Code with a QR Code reader app or extension. Android and iOS both have built-in QR code reader capabilities built into the Camera app.
* Write the OTP info to vault. The URL parameter value is what is encoded in the QR Code
    ```
    vault write totp/aws-root-accounts/keys/<account-name> url="<url-from-the-qr-code>"
    ```
  NOTE: The `url-from-the-qr-code` will look like: `otpauth://totp/some-provider-otp:some-user-id?secret=some-secret&issuer=some-issuer&period=30"`
* Read two consecutive verification codes and add them to AWS MFA page using the following command
    ```
    vault read totp/aws-root-accounts/code/<account-name>
    ```
### Verification

Don't forget to verify that you can log in with both 2FA settings.
