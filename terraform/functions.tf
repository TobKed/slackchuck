locals {
  source_object_file_name_prefix = "${var.region}/${var.project_id}/"
}


data "archive_file" "slackchuck" {
  type        = "zip"
  output_path = "${path.module}/files/slackchuck.zip"

  source {
    content  = "${file("${path.module}/../slackchuck.go")}"
    filename = "slackchuck.go"
  }

  source {
    content  = "${file("${path.module}/../go.mod")}"
    filename = "go.mod"
  }

  source {
    content  = "${file("${path.module}/../go.sum")}"
    filename = "go.sum"
  }
}

resource "google_storage_bucket_object" "slackchuck" {
  // we append hash to the filename as a temporary workaround for https://github.com/terraform-providers/terraform-provider-google/issues/1938
  name       = "${local.source_object_file_name_prefix}slackchuck-${lower(replace(base64encode(data.archive_file.slackchuck.output_md5), "=", ""))}.zip"
  bucket     = google_storage_bucket.functions.name
  source     = data.archive_file.slackchuck.output_path
  depends_on = [data.archive_file.slackchuck]
}

resource "google_cloudfunctions_function" "slackchuck" {
  name                  = "slackchuck"
  runtime               = "go113"
  trigger_http          = true
  entry_point           = "SlashCommandHandler"
  available_memory_mb   = 128
  timeout               = 5
  source_archive_bucket = google_storage_bucket.functions.name
  source_archive_object = google_storage_bucket_object.slackchuck.name
  environment_variables = {
    SLACK_VERIFICATION_TOKEN = var.slack_verification_token
  }

  labels = {
    slack = "slash_command"
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker-slackchuck" {
  project        = google_cloudfunctions_function.slackchuck.project
  region         = google_cloudfunctions_function.slackchuck.region
  cloud_function = google_cloudfunctions_function.slackchuck.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
