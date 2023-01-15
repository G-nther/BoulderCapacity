resource "google_cloudfunctions_function" "function" {
  name        = "${var.name}-${var.environment}"
  runtime     = "python39"

  available_memory_mb   = 128
  source_archive_bucket = "${var.code_bucket}"
  source_archive_object = "${var.code_archive}"
  trigger_http          = true
  entry_point           = "main"

  environment_variables = {
    CRAWLER_BUCKET = "${var.data_bucket}"
  }

  secret_environment_variables {
    key = "CRAWLER_URL"
    secret = "${var.name}-url"
    version = 1
  }
}