#!/bin/bash
splunk_hec_token=`aws secretsmanager get-secret-value --region us-east-1 --secret-id ci-instances-splunk-token-DQTxkM`
sed -i 's/httpEventCollectorToken =/httpEventCollectorToken =/httpEventCollectorToken =$splunk_hec_token' /opt/splunkforwarder/etc/system/local/outputs.conf
service splunk-forwarder restart
