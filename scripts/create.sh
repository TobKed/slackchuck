#!/usr/bin/env bash

# Stop immediately if something goes wrong
set -euo pipefail


run_terraform() {
  # Init with backend on gcs bucket
  (cd "$ROOT/terraform" && terraform init \
    -input=false \
    -backend-config="bucket=${PROJECT_ID}-tfstate")

  # Apply
  cd "$ROOT/terraform" && terraform apply \
    -var "project_id=${PROJECT_ID}" \
    -var "slack_verification_token=${SLACK_VERIFICATION_TOKEN}"
    -input=false \
    # -auto-approve \
}


ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

check_dependency_installed gcloud
check_dependency_installed terraform

get_project

# Check variables
check_variable_set "PROJECT_ID"
check_variable_set "SLACK_VERIFICATION_TOKEN"

# Enable required GCP services
enable_project_api "${PROJECT_ID}" cloudfunctions.googleapis.com
enable_project_api "${PROJECT_ID}" storage-api.googleapis.com
enable_project_api "${PROJECT_ID}" storage-component.googleapis.com
enable_project_api "${PROJECT_ID}" cloudbuild.googleapis.com


get_terraform_backend_bucket

run_terraform
