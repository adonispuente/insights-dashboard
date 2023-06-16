# Backplane access to AppSRE clusters

This doc is for AppSRE engineers who need to access AppSRE clusters via [backplane](/data/services/backplane/app.yaml)

**Note: This is not mandatory as of June 2023 but may become so in the future. For now, traditional cluster access via app-interface granted roles (view, admin) is still the common pattern**

## Install backplane

Installation instructions can be found in the [backplane-cli repository](https://github.com/openshift/backplane-cli) as well as in the [Source Wiki](https://source.redhat.com/groups/public/sre/wiki/backplane_user_documentation)

The following instructions are provided as a quick way to get started, however for the most up-to-date instructions please refer to the above links

1. Install [ocm-cli](https://github.com/openshift-online/ocm-cli)
1. Install [ocm-backplane](https://github.com/openshift/backplane-cli)

## Get access to backplane

Access to backplane is managed from the [ocm-resources repository](https://gitlab.cee.redhat.com/service/ocm-resources/)

1. Find out what your OCM username is. This is the one you use to login to OCM. Log in to https://console.redhat.com/openshift and verify you see AppSRE clusters. This username is usually in the form of `<kerberos_id>+sd-app-sre`
1. Submit a merge request to the ocm-resources repository, adding your user file under `/data/uhc-<environment>/users/<ocm_username>.yaml` with the following content:

    1. **For production (uhc-production)**

        This is usually what most people want. This will grant access to all AppSRE clusters, both production and staging ones as they all are configured under the OCM production environment

        ```yaml
        ---
        $schema: /user-1.yaml

        user_id: "<ocm_username>"

        kerberos_id: "<kerberos_username>"

        roles:
        - BackplaneCLI:
        - OSDFleetManagerViewer:
        - AppSRE:
            # AppSRE /data/uhc-production/orgs/12147054.yaml
            scope: Organization
            organization_id: "1OXqyqko0vmxpV9dmXe9oFypJIw"
        - SREP:
            # AppSRE /data/uhc-production/orgs/12147054.yaml
            scope: Organization
            organization_id: "1OXqyqko0vmxpV9dmXe9oFypJIw"
        - SREP:
            # OSD Fleet Manager - /data/uhc-production/orgs/15991019.yaml
            scope: Organization
            organization_id: "294LuIFKC3CgMDiYA1t5X1gQPJq"

        environment: "uhc-production"

        # Your Alpha-3 country code from https://www.iban.com/country-codes
        capabilities:
        - key: "capability.account.legal_entity"
          value: "XYZ"
        ```

    1. **For staging (uhc-staging)**

        Few people may need this. This will grant access to ALL clusters created under the staging OCM environment

        ```yaml
        ---
        $schema: /user-1.yaml

        user_id: "<ocm_username>"

        kerberos_id: "<kerberos_username>"

        roles:
        - APPSRE:
        - SREPLead:
        - SREPDeveloper:

        environment: "uhc-stage"

        # Your Alpha-3 country code from https://www.iban.com/country-codes
        capabilities:
        - key: "capability.account.legal_entity"
          value: "XYZ"
        ```

## Use backplane

1. Get a token for use with the ocm cli: https://console.redhat.com/openshift/token
1. Login to OCM

    ```sh
    ocm login --token="..."
    ```

1. Configure backplane

    ```sh
    $ mkdir -p ~/.config/backplane
    $ cat << EOF > ~/.config/backplane/config.json
    {
        "url": "https://api.backplane.openshift.com",
        "proxy-url": "http://squid.corp.redhat.com:3128"
    }
    EOF
    ```

3. Find a cluster to login to

    ```sh
    ocm list clusters
    ```

4. Login to a cluster via backplane

    ```sh
    ocm backplane login <cluster_name/cluster_id>
    ```

# FAQ

## How to find the Organization ID I am part of?

```sh
$ ocm whoami

{
  "kind": "Account",
  "id": "1QQIJdWSSILERWvHa2Pn4ajaoXw",
  "href": "/api/accounts_mgmt/v1/accounts/1QQIJdWSSILERWvHa2Pn4ajaoXw",
  "created_at": "2019-09-05T15:12:02Z",
  "email": "jchevret@redhat.com",
  "first_name": "Jean-Francois",
  "last_name": "Chevrette",
  "organization": {
    "kind": "Organization",
    "id": "1OXqyqko0vmxpV9dmXe9oFypJIw",
    "href": "/api/accounts_mgmt/v1/organizations/1OXqyqko0vmxpV9dmXe9oFypJIw",
    "created_at": "2019-07-26T09:49:06Z",
    "ebs_account_id": "6341237",
    "external_id": "12147054",
    "name": "Red Hat",
    "updated_at": "2023-06-16T11:46:25Z"
  },
  "rhit_web_user_id": "52842059",
  "updated_at": "2023-06-16T05:10:39Z",
  "username": "jchevret+sd-app-sre"
}

$ ocm list org
```
