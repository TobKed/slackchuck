resource "google_secret_manager_secret" "slack_token" {
  provider = google-beta

  secret_id = "slack-token"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "slack_token" {
  provider = google-beta

  secret      = google_secret_manager_secret.slack_token.id
  secret_data = var.slack_verification_token
}
