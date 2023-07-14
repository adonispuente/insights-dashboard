# Base Functionality Test for Automation Hub

## Summary

Details base functionality test instructions. This tests [Automation Hub][automation-hub-gitlab].

Search, browse and dowload certified ansible collections.

## Access required

- [console.redhat.com][consoledot] or [console.stage.redhat.com][stageconsoledot] account with
  access to insights.

## Steps

### UI
1. Go to the [Automation Hub][automation-hub-crc] page on console.redhat.com. A page of collections will appear.
2. Use the search filter to search for a collection, e.g `aws`
3. Select the `aws` collection provided by `amazon` from the search results. If it does not appear on the first page of results you may have to browse additional pages to find it. Otherwise, you can select any other collection.
4. Click `Download tarball` to download the collection. 

The download should start immediately and appear in your downloads directory.



### CLI

The `ansible-galaxy` CLI is available in both the `ansible` and `ansible-core` packages. See the [ansible documentation][ansible-docs] for installation instructions.

Obtain your RedHat SSO account token. It is available from the [Automation Hub UI][automation-hub-token]

1. In a terminal window, create an `ansible.cfg` file in your working directory with the contents below, replacing `<TOKEN>` with your SSO token.
```
[galaxy]
server_list = automation-hub

[galaxy_server.automation-hub]
url=https://console.redhat.com/api/automation-hub/content/published/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token=<TOKEN>
```

2. Run the following command to download the `aws` collection to your working directory.
 ```
 ansible-galaxy collection download --download-path "./" amazon.aws
 ```

 When the command completes, the collection tarball (e.g. `amazon-aws-z.y.z.tar.gz`) and a `requirements.yml` should be present in your working directory.


[automation-hub-gitlab]:  https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/insights/automation-hub
[automation-hub-crc]:     https://console.redhat.com/ansible/automation-hub/
[automation-hub-token]:   https://console.redhat.com/ansible/automation-hub/token
[consoledot]:             https://console.redhat.com
[stageconsoledot]:        https://console.stage.redhat.com
[ansible-docs]:           https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html
