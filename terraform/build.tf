resource "google_cloudbuild_trigger" "test_trigger" {
  provider = google-beta

  name        = "test-trigger"
  description = "Test trigger requires comment /gcbrun to perform terraform plan"
  filename    = "cloudbuild/test.yml"

  github {
    owner = "TobKed"
    name  = "slackchuck"
    pull_request {
      branch          = ".*"
      comment_control = "COMMENTS_ENABLED"
    }
  }
}

resource "google_cloudbuild_trigger" "deploy_trigger" {
  provider = google-beta

  name        = "deploy-trigger"
  description = "Deploy trigger perform terraform apply"
  filename    = "cloudbuild/deploy.yml"

  github {
    owner = "TobKed"
    name  = "slackchuck"
    push {
      branch = "^master$"
    }
  }
}
