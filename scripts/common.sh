#! /usr/bin/env bash

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Common commands for all scripts                      -"
# "-                                                       -"
# "---------------------------------------------------------"

# Check if required binaries exist
# Globals:
#   None
# Arguments:
#   DEPENDENCY - The command to verify is installed.
# Returns:
#   None
check_dependency_installed () {
  command -v "${1}" >/dev/null 2>&1 || { \
  echo >&2 "${1} is required but is not installed. Aborting."; exit 1; }
}

# Helper function to enable a given service for a given project
# Globals:
#   None
# Arguments:
#   PROJECT_ID - ID of the project in which to enable the API
#   API     - Name of the API to enable, e.g. compute.googleapis.com
# Returns:
#   None
enable_project_api() {
  gcloud services enable "${2}" --project "${1}"
}

# Helper function to return configured GCP project
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PROJECT_ID - name of the currently configured project
get_project() {
  # gcloud config holds values related to your environment. If you already
  # defined a default project we will retrieve it and use it
  PROJECT_ID=$(gcloud config get-value core/project)
  if [[ -z "${PROJECT_ID}" ]]; then
      echo "gcloud cli must be configured with a default project." 1>&2
      echo "run 'gcloud config set core/project PROJECT_ID'." 1>&2
      echo "replace 'PROJECT_ID' with the project name." 1>&2
      exit 1;
  fi
  return 0
}

# Check if given variable is set
# Globals:
#   None
# Arguments:
#   NAME - Name of the variable to be checked
#   VARIABLE - Value of the variable to be checked
# Returns:
#   None
check_variable_set() {
  if [[ -z ${!1-} ]]; then
    echo "Variable \"${1}\" have to be set!" 1>&2
    exit 1;
  fi
  return 0
}

# Helper function to return configured GCP bucket for Terraform state
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   TERRAFORM_BACKEND_BUCKET - name of the bucket
get_terraform_backend_bucket() {
  TERRAFORM_BACKEND_BUCKET="${PROJECT_ID}-tfstate"
  echo "Terraform backend state will be present on GCS bucket: gs://${TERRAFORM_BACKEND_BUCKET}"
  gsutil ls -b "gs://${TERRAFORM_BACKEND_BUCKET}" >/dev/null 2>&1 || \
    (gsutil mb "gs://${TERRAFORM_BACKEND_BUCKET}" && gsutil versioning set on "gs://${TERRAFORM_BACKEND_BUCKET}")
  return 0
}

# Helper function to destroy configured GCP bucket for Terraform state
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   TERRAFORM_BACKEND_BUCKET - name of the bucket
delete_terraform_backend_bucket() {
  TERRAFORM_BACKEND_BUCKET="${PROJECT_ID}-tfstate"
  echo
  echo "Do you want to delete bucket gs://${TERRAFORM_BACKEND_BUCKET} ?"
  ask_for_confirmation
  gsutil ls -b "gs://${TERRAFORM_BACKEND_BUCKET}" && gsutil -m rm -r "gs://${TERRAFORM_BACKEND_BUCKET}"
  return 0
}

# Helper function to ask yes/no question.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
ask_for_confirmation() {
  echo
  echo "Please answer yes or no."
  while true; do
      read -p "Answer: " yn
      case $yn in
          Yes|yes ) echo; break;;
          No|no ) echo "Quitting..."; exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}
