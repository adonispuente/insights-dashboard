#!/bin/bash

source <(git show HEAD:.env)

latest_tag() {
    repo=$(basename $1)
    org=$(basename $(dirname $1))
    jqcmd='.images[] | select(.tags[] | contains("latest")).tags | .[] | select(. != "latest")'
    curl -s https://quay.io/api/v1/repository/$org/$repo/image/ | jq -r "$jqcmd"
}

NEW_QONTRACT_SERVER_IMAGE_TAG=$(latest_tag $QONTRACT_SERVER_IMAGE)
NEW_VALIDATOR_IMAGE_TAG=$(latest_tag $VALIDATOR_IMAGE)
NEW_RECONCILE_IMAGE_TAG=$(latest_tag $RECONCILE_IMAGE)

cat <<EOF
export QONTRACT_SERVER_REPO=$QONTRACT_SERVER_REPO
export QONTRACT_SERVER_IMAGE=$QONTRACT_SERVER_IMAGE
export QONTRACT_SERVER_IMAGE_TAG=$NEW_QONTRACT_SERVER_IMAGE_TAG

export VALIDATOR_REPO=$VALIDATOR_REPO
export VALIDATOR_IMAGE=$VALIDATOR_IMAGE
export VALIDATOR_IMAGE_TAG=$NEW_VALIDATOR_IMAGE_TAG

export RECONCILE_REPO=$RECONCILE_REPO
export RECONCILE_IMAGE=$RECONCILE_IMAGE
export RECONCILE_IMAGE_TAG=$NEW_RECONCILE_IMAGE_TAG
EOF

github_compare() {
    REPO=$1
    FROM=$2
    TO=$3

    [ "$FROM" != "$TO" ] && echo $REPO/compare/$FROM...$TO >&2
}

github_compare $QONTRACT_SERVER_REPO $QONTRACT_SERVER_IMAGE_TAG $NEW_QONTRACT_SERVER_IMAGE_TAG
github_compare $VALIDATOR_REPO $VALIDATOR_IMAGE_TAG $NEW_VALIDATOR_IMAGE_TAG
github_compare $RECONCILE_REPO $RECONCILE_IMAGE_TAG $NEW_RECONCILE_IMAGE_TAG
