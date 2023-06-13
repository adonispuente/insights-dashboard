# TODO: convert me to a Job
# TODO: render variables
DT_API_URL=https://ddl70254.live.dynatrace.com/api/v2
CLUSTER_NAME="appsre-appint-ex-01"
RULE_NAME="log-cluster-namespaces"
# Lets give the DT stack a total of 10 minutes to bootstrap
MAX_TRIES=30
SLEEP_TIME_IN_S=20

for ((i=1; i<=$MAX_TRIES; i++))
do
    hostGroupData=$(curl -s -X GET -H "Authorization: Api-Token $DYNATRACE_API_TOKEN" -H "Content-Type: application/json" "$DT_API_URL/entities?entitySelector=type(\"HOST_GROUP\"),entityName(\"$CLUSTER_NAME\")&fields=properties")
    totalCount=$(echo "$hostGroupData" | jq -r '.totalCount')
    if [ "$totalCount" -eq 1 ]; then
        hostGroupId=$(echo $hostGroupData | jq -r '.entities[0].entityId')
        break  # Exit the loop since condition is met
    else
        echo "$DT_API_URL returned $totalCount occurrences of $CLUSTER_NAME amongst Dynatrace HOST_GROUPS. Retrying in $SLEEP_TIME_IN_S seconds..."
        sleep $SLEEP_TIME_IN_S  # Wait for specified time before retrying
    fi

    if [ $i -eq $MAX_TRIES ]; then
        echo "Reached maximum number of tries. Exiting..."
        exit 1
    fi
done

ruleObjectId=$(curl -s -X GET -H "Authorization: Api-Token $DYNATRACE_API_TOKEN" -H "Content-Type: application/json" "$DT_API_URL/settings/objects?schemaIds=builtin:logmonitoring.log-storage-settings&scopes=$hostGroupId" | jq -r '.items[] | select(.value."config-item-title" == "'$RULE_NAME'") | .objectId')

if [[ -n "$ruleObjectId" ]]; then
  echo "There already exists a logging rule for cluster $CLUSTER_NAME. Lets adjust the existing one!"
  # https://www.dynatrace.com/support/help/dynatrace-api/environment-api/settings/objects/put-object
  curl -s -X PUT -H "Authorization: Api-Token $DYNATRACE_API_TOKEN" -H "Content-Type: application/json" -d '{"schemaId": "builtin:logmonitoring.log-storage-settings", "scope": "'$hostGroupId'", "value": {"enabled": false, "config-item-title": "'$RULE_NAME'", "send-to-storage": true, "matchers": [{"attribute": "k8s.namespace.name", "operator": "MATCHES", "values": ["kfischer"]}]}}' "$DT_API_URL/settings/objects/$ruleObjectId"
else
  echo "No logging rule for cluster $CLUSTER_NAME yet. Lets create a new one!"
  # https://www.dynatrace.com/support/help/dynatrace-api/environment-api/settings/schemas/builtin-logmonitoring-log-storage-settings
  curl -s -X POST -H "Authorization: Api-Token $DYNATRACE_API_TOKEN" -H "Content-Type: application/json" -d '[{"schemaId": "builtin:logmonitoring.log-storage-settings", "scope": "'$hostGroupId'", "value": {"enabled": false, "config-item-title": "'$RULE_NAME'", "send-to-storage": true, "matchers": [{"attribute": "k8s.namespace.name", "operator": "MATCHES", "values": ["kfischer", "kfischer2"]}]}}]' "$DT_API_URL/settings/objects"
fi
