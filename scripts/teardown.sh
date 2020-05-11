#!/usr/bin/env bash

# Stop immediately if something goes wrong
set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

check_dependency_installed gcloud
check_dependency_installed terraform

get_project

check_variable_set "PROJECT_ID"


# Destroy
(cd "${ROOT}/terraform" && terraform destroy \
  -var "project_id=${PROJECT_ID}" \
  -var "slack_verification_token=${SLACK_VERIFICATION_TOKEN}"
)
