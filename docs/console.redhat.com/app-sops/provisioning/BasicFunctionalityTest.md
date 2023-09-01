# Basic Functionality Test

## Summary

Details basic functionality test instructions. This tests [Insights Image Launch][insights-launch].

Simple build of an image and Launch of it in AWS EC2.

## Access required

- [console.redhat.com][consoledot] account with access to Insights
- Launch Admin role in ConsoleDot RBAC.
- [Cloud integration][consoledotsources] (Integration for AWS with AWS account connected) or permissions to create one.

## Steps

### API

API is bit easier as it does not need an Image build as prerequisite.
Although it requires you to create an AWS account connection ahead of time.
If you're using an account under AppSRE organization on ConsoleDot,
you can just use following request where we use already prepared AWS account and preuploaded public key:

1. Set `$USER` and `$PASSWD` variables to your user under AppSRE account for [console.redhat.com][consoledot].

2. Send the request for AWS machine reservation:
```
pubkeyID=397
sourceID=463014

reservationID=$(curl --location -g --request POST "https://console.redhat.com/api/provisioning/v1/reservations/aws" \
-u "$USER:$PASSWD" \
-d "$(cat <<EOF
{
  "amount": 1,
  "image_id": "ami-0c41531b8d18cc72b",
  "instance_type": "t3.micro",
  "poweroff": true,
  "pubkey_id": $pubkeyID,
  "region": "us-east-1",
  "source_id": "$sourceID"
}
EOF
)" | jq -r '.reservation_id')
```

3. Poll the status until it returns `success: true`.
```
curl -u '$USER:$PASSWD' https://console.redhat.com/api/provisioning/v1/reservations/$reservationID
```

4. Once it does you can get the instance id by

```
curl -u '$USER:$PASSWD' https://console.redhat.com/api/provisioning/v1/reservations/aws/$reservationID
```

It should return instance id within AppSRE AWS account (id = `950916221866`)
and by now it should be stopped (as we requested by `poweroff: true`).
Don't forget to terminate it! :)

### UI

1. Go to [Image Builder][consoledotib]

1. Click `Create Image`. In the wizard choose a `AWS`. Select the the AWS source. Choose `Register
   later` on the Registration page.

1. Click through to the Review page and click `Create Image`.

An image build will be queued, which takes a while to build ~ 4-10mins.

1. On the overview page wait until the status is green and `Launch` button appears.

1. Click `Launch`, select your AWS account, any micro instance type, click `Next`.

1. Choose the ssh key.

1. Confirm and see the process of Launching the instance.

1. After few seconds, green check and table with launched instance details appears.


[insights-launch]:        https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/insights/provisioning
[consoledot]:             https://console.redhat.com
[consoledotsources]:      https://console.redhat.com/settings/sources?category=Cloud
[consoledotib]:           https://console.redhat.com/beta/insights/image-builder
