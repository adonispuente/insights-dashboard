# Cost Management

[TOC]

## Overview

[Cost Management](https://access.redhat.com/products/red-hat-cost-management/) is an OpenShift Container Platform service that
enables you to better understand and track costs for clouds and containers. 
It is based on the upstream project Koku.

For App-SRE, AWS costs are imported, OpenShift costs will be imported in the future.

## Access

1. Submit [Cost Management User Access for App-SRE Costs](https://docs.google.com/forms/d/e/1FAIpQLSfd7RPsr6EsVYs0L2IbbKK3D_7FbtKFdX1BYYEaAm_whdxNGg/viewform) form
2. Wait for an invite email `Red Hat Login Email Verification` for the new account, account name will be `<LDAP>cc`
3. Activate the account following the instructions in the email
4. Login to [Cost Management](https://console.redhat.com/openshift/cost-management) with the new account

## Add new AWS account

Submit [Add New AWS Account to Cost Management for App-SRE Costs](https://docs.google.com/forms/d/e/1FAIpQLSfHgHGL1ZkdXhusbm5svCQcUsebzvhm8r8DSOs1GFHPa6GThg/viewform) form.

If the AWS account is not a payer account, just need to fill `Provide the AWS Account number`.

If the AWS account is a payer account, usually it's not setup by App-SRE, should contact the account owner for setup.

If we need to setup the payer account, then follow [Adding an Amazon Web Services (AWS) source to cost management](https://access.redhat.com/documentation/en-us/cost_management_service/2023/html/adding_an_amazon_web_services_aws_source_to_cost_management/index),
and fill out the rest of the form.
