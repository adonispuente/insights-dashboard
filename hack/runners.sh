#!/bin/bash

run_int() {
  local status

  INTEGRATION_NAME="${ALIAS:-$1}"
  [ -n "$DRY_RUN" ] && DRY_RUN_FLAG="--dry-run"
  [ -n "$SQS_GATEWAY" ] && GITLAB_PR_SUBMITTER_QUEUE_URL_ENV="-e gitlab_pr_submitter_queue_url=$gitlab_pr_submitter_queue_url"
  [ -n "$STATE" ] && APP_INTERFACE_STATE_ENV="-e APP_INTERFACE_STATE_BUCKET=$app_interface_state_bucket -e APP_INTERFACE_STATE_BUCKET_ACCOUNT=$app_interface_state_bucket_account"

  echo "INTEGRATION $INTEGRATION_NAME" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v ${WORK_DIR}/config:/config:z \
    -v /etc/pki:/etc/pki:z \
    -v ${WORK_DIR}/throughput:/throughput:z \
    -v /var/tmp/.cache:/root/.cache:z \
    -e GITHUB_API=$GITHUB_API \
    -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
    $GITLAB_PR_SUBMITTER_QUEUE_URL_ENV \
    $APP_INTERFACE_STATE_ENV \
    -w / \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    qontract-reconcile --config /config/config.toml $DRY_RUN_FLAG $@ \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt

  status="$?"
  ENDTIME=$(date +%s)

  echo "app_interface_int_execution_duration_seconds{integration=\"$INTEGRATION_NAME\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: $1" >&2
    mv ${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt ${FAIL_DIR}/reconcile-${INTEGRATION_NAME}.txt
  fi

  return $status
}

run_test() {
  echo "TEST $1" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v ${WORK_DIR}/config:/config:z \
    -v /etc/pki:/etc/pki:z \
    -v ${WORK_DIR}/throughput:/throughput:z \
    -w / \
    -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    e2e-tests --config /config/config.toml $@ \
    2>&1 | tee ${SUCCESS_DIR}/e2e-test-${1}.txt
  EXIT_STATUS=$?
  ENDTIME=$(date +%s)

  echo "$1 $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/test_execution_duration_seconds.txt"

  if [ "$EXIT_STATUS" != "0" ]; then
    mv ${SUCCESS_DIR}/e2e-test-${1}.txt ${FAIL_DIR}/e2e-test-${1}.txt
    return 1
  fi

  return 0
}

run_vault_reconcile_integration() {
  local status

  [ -n "$DRY_RUN" ] && DRY_RUN_FLAG="-dry-run"
  echo "INTEGRATION vault" >&2

  STARTTIME=$(date +%s)
  docker run --rm -t \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e GRAPHQL_USERNAME=${GRAPHQL_USERNAME} \
    -e GRAPHQL_PASSWORD=${GRAPHQL_PASSWORD} \
    -e VAULT_ADDR=https://vault.devshift.net \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${VAULT_MANAGER_ROLE_ID} \
    -e VAULT_SECRET_ID=${VAULT_MANAGER_SECRET_ID} \
    ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG} $DRY_RUN_FLAG \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-vault.txt

  status="$?"
  ENDTIME=$(date +%s)

  # Add integration run durations to a file
  echo "app_interface_int_execution_duration_seconds{integration=\"vault\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: vault" >&2
    mv ${SUCCESS_DIR}/reconcile-vault.txt ${FAIL_DIR}/reconcile-vault.txt
  fi

  return $status
}

print_execution_times() {
    echo
    echo "Execution times for integrations that were executed"
    (
      echo "Integration Seconds"
      sort -nr -k2 "${SUCCESS_DIR}/int_execution_duration_seconds.txt"
    ) | column -t
    echo
}

check_results() {
    FAILED_COUNT=$(ls ${FAIL_DIR} | wc -l)

    if [ "$FAILED_COUNT" != "0" ]; then
      CONFLICT=$(find ${FAIL_DIR} -type f -exec cat {} + | grep "409: Conflict" | wc -l)
      RATE_LIMITED=$(find ${FAIL_DIR} -type f -exec cat {} + | grep "ratelimited" | wc -l)
      [ "$CONFLICT" == "0" ] && [ "$RATE_LIMITED" == "0" ] && FAIL_EXIT_STATUS=1 || FAIL_EXIT_STATUS=80
      exit $FAIL_EXIT_STATUS
    fi
}

wait_response() {
    local count=0
    local max=10

    URL=$1
    EXPECTED_RESPONSE=$2

    while [[ ${count} -lt ${max} ]]; do
        let count++ || :
        RESPONSE=$(curl -s $URL)
        [[ "$EXPECTED_RESPONSE" == "$RESPONSE" ]] && break || sleep 10
    done

    if [[ "$EXPECTED_RESPONSE" != "$RESPONSE" ]]; then
      echo "Invalid response." >&2
      echo "Expecting:\n$EXPECTED_RESPONSE" >&2
      echo "Got:\n$RESPONSE" >&2
      exit 1
    fi
}

upload_s3() {
    INPUT_FILE=$1

    SHA256=$(sha256sum $INPUT_FILE | awk '{print $1}')
    aws s3 cp $INPUT_FILE s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}
    wait_response \
        "https://${GRAPHQL_USERNAME}:${GRAPHQL_PASSWORD}@${GRAPHQL_SERVER_BASE_URL}/sha256" \
        "$SHA256"
}

update_pushgateway() {
    echo "Sending Integration execution times to Push Gateway"

    (echo '# TYPE app_interface_int_execution_duration_seconds gauge'; \
      echo '# HELP app_interface_int_execution_duration_seconds App-interface integration run times in seconds'; \
      cat ${SUCCESS_DIR}/int_execution_duration_seconds.txt) | \
      curl -v -X POST -s -H "Authorization: Basic ${PUSHGW_CREDS}" --data-binary @- $PUSHGW_URL/metrics/job/$JOB_NAME
}
