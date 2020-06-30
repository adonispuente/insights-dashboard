#!/bin/bash

set -o pipefail

usage() {
    echo "$0 DATAFILES_BUNDLE [CONFIG_TOML]" >&1
    exit 1
}

if [ `uname -s` = "Darwin" ]; then
  sha256sum() { shasum -a 256 "$@" ; }
  QONTRACT_SERVER_DOCKER_OPTS="-p 4000:4000"
fi

CURRENT_DIR=${CURRENT_DIR:-./hack}
TEMP_DIR=${TEMP_DIR:-./temp}
WORK_DIR=$(realpath -s $TEMP_DIR)

DATAFILES_BUNDLE="$1"
[ -z "${DATAFILES_BUNDLE}" ] && usage

CONFIG_TOML="$2"
[ -z "${CONFIG_TOML}" ] && usage

DATAFILES_BUNDLE_BASENAME=$(basename ${DATAFILES_BUNDLE})
DATAFILES_BUNDLE_DIR=$(dirname $(realpath -s ${DATAFILES_BUNDLE}))

# write .env file
cat <<EOF >${WORK_DIR}/.qontract-server-env
LOAD_METHOD=fs
DATAFILES_FILE=/validate/${DATAFILES_BUNDLE_BASENAME}
EOF

# start graphql-server locally
qontract_server=$(
  docker run --rm -d $QONTRACT_SERVER_DOCKER_OPTS \
    -v ${DATAFILES_BUNDLE_DIR}:/validate:z \
    --env-file=${WORK_DIR}/.qontract-server-env \
    ${QONTRACT_SERVER_IMAGE}:${QONTRACT_SERVER_IMAGE_TAG}
)

if [ -z "$qontract_server" ]; then
  echo "Could not start qontract server" >&2
  exit 1
fi

# Setup trap to execute after the script exits
trap "docker stop $qontract_server >/dev/null" EXIT

# get network conf
IP=$(docker inspect \
      -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
      ${qontract_server})

if [ `uname -s` = 'Darwin' ]; then
  CURL_IP=localhost
else
  CURL_IP=$IP
fi

source $CURRENT_DIR/runners.sh

# Run integrations

DRY_RUN=true

## Create directories for integrations
mkdir -p ${WORK_DIR}/config
mkdir -p ${WORK_DIR}/throughput
SUCCESS_DIR=${WORK_DIR}/reports/reconcile_reports_success
FAIL_DIR=${WORK_DIR}/reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

# Prepare to run integrations on production

## Write config.toml for reconcile tools
cat "$CONFIG_TOML" > ${WORK_DIR}/config/config.toml

# Gatekeeper. If this fails, we skip all the integrations.
run_int gitlab-fork-compliance $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid app-sre && {

## Run integrations on production
ALIAS=jenkins-job-builder-no-compare run_int jenkins-job-builder --no-compare &
ALIAS=saas-file-owners-no-compare run_int saas-file-owners $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid --no-compare &

# Prepare to run integrations on local server

## Wait until the service loads the data
SHA256=$(sha256sum ${DATAFILES_BUNDLE} | awk '{print $1}')
while [[ ${count} -lt 20 ]]; do
    let count++
    DEPLOYED_SHA256=$(curl -sf http://${CURL_IP}:4000/sha256)
    [[ "$DEPLOYED_SHA256" == "$SHA256" ]] && break || sleep 1
done

if [[ "$DEPLOYED_SHA256" != "$SHA256" ]]; then
  echo "Invalid SHA256" >&2
  exit 1
fi

## Wait for production integrations to complete

wait

## Write config.toml for reconcile tools
GRAPHQL_SERVER=http://$IP:4000/graphql
cat "$CONFIG_TOML" \
  | sed "s|https://app-interface.devshift.net/graphql|$GRAPHQL_SERVER|" \
  > ${WORK_DIR}/config/config.toml

## Run integrations on local server

### saas-file-owners runs first to determine how openshift-saas-deploy-wrappers should run
run_int saas-file-owners $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid

# if changes are only to saas files, skip all other integrations
[[ "$(cat ${WORK_DIR}/throughput/saas-file-owners/diffs.json | jq .valid_saas_file_changes_only)" != "true" ]] && {
run_int github &
run_int github-owners &
run_int github-validator &
run_int github-repo-invites &
run_int github-repo-permissions-validator ci-ext app-sre &
run_int service-dependencies &
run_int user-validator &
run_int quay-membership &
run_int quay-repos &
run_vault_reconcile_integration &
run_int ocm-clusters &
run_int ocm-groups &
run_int ocm-aws-infrastructure-access &
run_int ocm-github-idp --vault-input-path app-sre/integrations-input &
run_int openshift-groups &
run_int openshift-users &
run_int jenkins-plugins &
run_int jenkins-roles &
run_int jenkins-job-builder &
run_int jenkins-webhooks &
run_int jenkins-webhooks-cleaner &
run_int aws-iam-keys &
run_int gitlab-members &
run_int gitlab-projects &
run_int gitlab-permissions &
run_int gitlab-integrations &
run_int openshift-namespaces &
run_int openshift-clusterrolebindings &
run_int openshift-rolebindings &
run_int openshift-resources &
run_int openshift-vault-secrets &
run_int openshift-routes &
run_int openshift-network-policies &
run_int openshift-limitranges &
# run_int openshift-resourcequotas &
run_int openshift-serviceaccount-tokens &
run_int terraform-resources &
run_int terraform-users &
run_int terraform-vpc-peerings &
run_int ldap-users $gitlabMergeRequestTargetProjectId &
run_int openshift-performance-parameters &
run_int saas-file-validator &
# Conditionally run integrations according to MR title
[[ "$(echo $gitlabMergeRequestTitle | tr '[:upper:]' '[:lower:]')" == *"slack"* ]] && run_int slack-usergroups &
[[ "$(echo $gitlabMergeRequestTitle | tr '[:upper:]' '[:lower:]')" == *"sentry"* ]] && run_int sentry-config &
[[ "$(echo $gitlabMergeRequestTitle | tr '[:upper:]' '[:lower:]')" == *"mirror"* ]] && run_int quay-mirror &
[[ "$(echo $gitlabMergeRequestTitle | tr '[:upper:]' '[:lower:]')" == *"saas-deploy-full"* ]] && run_int openshift-saas-deploy &
# Add STATE=true to integrations that interact with a state
STATE=true run_int sql-query &
STATE=true run_int email-sender &
STATE=true run_int requests-sender &
} # end of skip all other integrations

STATE=true run_int openshift-saas-deploy-trigger-configs &
run_int openshift-saas-deploy-wrapper &

wait
}

print_execution_times
update_pushgateway
check_results
