#!/usr/bin/env bash

# Stop immediately if something goes wrong
set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

check_dependency_installed gcloud

get_project

echo "This script will destroy bucket where terraform backend status is stored."
delete_terraform_backend_bucket
