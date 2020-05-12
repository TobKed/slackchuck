data "google_iam_policy" "cloud_build_sa" {
  binding {
    role = "roles/owner"

    members = [
      "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}
